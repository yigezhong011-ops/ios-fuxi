#!/bin/bash
set -euo pipefail
B=/root/fuxi/authbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
FW=/root/fuxi/fw-correct
mkdir -p "$B"
cp "$SRC"/*.c "$SRC"/*.S "$SRC"/*.ld "$B"/ 2>/dev/null || true
cp "$SRC"/adt.py "$B"/ 2>/dev/null || true

# 正确的 GPU 固件
cat > "$B/gpu-fw.S" <<'EOF'
.section .gpu_fw,"a"
.balign 4
.global _gpu_fw_start
_gpu_fw_start:
.incbin "/root/fuxi/fw-correct/gmu_gen70200.bin"
.global _gpu_fw_end
_gpu_fw_end:
.global _sqe_fw_start
_sqe_fw_start:
.incbin "/root/fuxi/fw-correct/a740_sqe.fw"
.global _sqe_fw_end
_sqe_fw_end:
.global _zap_fw_start
_zap_fw_start:
.incbin "/root/fuxi/fw-correct/a740_zap.mbn"
.global _zap_fw_end
_zap_fw_end:
EOF

# 作者的 payload（cpus=6）
printf '.section .payload,"a"\n.incbin "/root/fuxi/payload-pkg.bin"\n' > "$B/payload.S"

# 加回 probe_main 调用
python3 - "$B/loader.c" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if 'probe_main(fdt);' in t:
    print('already patched')
else:
    old = ' (void)fdt;'
    assert old in t, 'anchor missing'
    t = t.replace(old, ' probe_main(fdt);', 1)
    p.write_text(t)
    print('probe_main(fdt) 已加回')
PY

cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
for f in start.S loader.c console.c probe.c payload.S gpu-fw.S; do
  o="${f%.*}.o"
  echo "CC $f"
  clang $CFLAGS -c "$f" -o "$o"
done
echo "LD"
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
ls -l Image

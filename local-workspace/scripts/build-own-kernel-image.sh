#!/bin/bash
# Build the boot image for the "our kernel + their loader/ADT" combination.
#
#   payload  = our CI kernel (with kern.exec_inject, patch 0116)
#            + the author's fuxi-root.adt (root at userdata offset 0)
#            + the author's cmdline with cpus=6
#   loader   = the author's sources, unmodified (no probe_main: that is what
#              crashed earlier), with the TZ-accepted GPU firmware
set -euo pipefail

B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
FW=/root/fuxi/fw-correct
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working

[ -f "$KERNEL" ] || { echo "missing $KERNEL"; exit 1; }
[ -f "$ADT" ] || { echo "missing $ADT"; exit 1; }

mkdir -p "$B"
cp "$SRC"/*.c "$SRC"/*.S "$SRC"/*.ld "$B"/ 2>/dev/null || true

echo "=== 1) cmdline（作者的，cpus 6）==="
CMDLINE=$(python3 - "$PKG/payload.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
print(cmd.replace('cpus=7', 'cpus=6'))
PY
)
echo "$CMDLINE" | cut -c1-200

echo "=== 2) payload = 我们的内核 + 作者的 ADT ==="
python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" 2>&1 | tail -3
ls -l "$B/payload.bin"

echo "=== 3) 用作者源码编译 loader（不带 probe_main）==="
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
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"

cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
rm -f ./*.o loader.elf Image
for f in start.S loader.c console.c probe.c payload.S gpu-fw.S; do
  echo "  CC $f"
  clang $CFLAGS -c "$f" -o "${f%.*}.o"
done
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
ls -l Image

echo "=== 4) 打包成 boot 镜像 ==="
python3 "$SRC/packboot4.py" "$B/Image" /mnt/e/DSH-Fuxi/fuxi-ownkernel.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-ownkernel.img
echo OWNKERNEL_OK

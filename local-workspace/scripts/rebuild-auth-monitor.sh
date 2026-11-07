#!/bin/bash
set -euo pipefail
B=/root/fuxi/authbuild
S="$B/start.S"

python3 - "$S" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if 'fuxi_mmu_off_auth' in t:
    print('already patched'); raise SystemExit
anchor = '2:\n mov x0, x19\n bl loader_main'
assert anchor in t, 'anchor missing'
patch = '''2:
fuxi_mmu_off_auth:
 mrs x1, sctlr_el1
 bic x1, x1, #1
 bic x1, x1, #4
 bic x1, x1, #0x1000
 dsb sy
 msr sctlr_el1, x1
 isb
 dsb sy
 isb
 mov x0, x19
 bl loader_main'''
t = t.replace(anchor, patch, 1)
p.write_text(t)
print('start.S: MMU/cache 关闭序列已插入')
PY

cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
rm -f ./*.o loader.elf Image
for f in start.S loader.c console.c probe.c payload.S gpu-fw.S; do
  echo "CC $f"
  clang $CFLAGS -c "$f" -o "${f%.*}.o"
done
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 /mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src/packboot4.py "$B/Image" /mnt/e/DSH-Fuxi/fuxi-authmon2.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-authmon2.img

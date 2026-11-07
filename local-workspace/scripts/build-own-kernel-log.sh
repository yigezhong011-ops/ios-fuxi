#!/bin/bash
# Rebuild the boot image with the logging kernel and the screen console on.
set -euo pipefail
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working

CMDLINE=$(python3 - "$PKG/payload.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6')
# the screen console: the only log channel this loader has
cmd = cmd.replace(' sweetfb_noconsole=1', '')
print(cmd)
PY
)
echo "=== cmdline（已开屏幕控制台）==="
echo "$CMDLINE" | tr ' ' '\n' | grep -E 'noconsole|cpus=|debug=' | sed 's/^/  /'

echo "=== payload ==="
python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" 2>&1 | tail -2

printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
rm -f ./*.o loader.elf Image
for f in start.S loader.c console.c probe.c payload.S gpu-fw.S; do
  clang $CFLAGS -c "$f" -o "${f%.*}.o"
done
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" /mnt/e/DSH-Fuxi/fuxi-ownkernel-log.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-ownkernel-log.img
echo OWNKERNEL_LOG_OK

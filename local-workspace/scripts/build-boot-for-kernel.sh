#!/bin/bash
# Rebuild the boot image around a chosen kernel (panic diagnostic build).
set -euo pipefail
KERNEL=${1:?usage: build-boot-for-kernel.sh <kernel> <out.img>}
OUT=${2:?usage: build-boot-for-kernel.sh <kernel> <out.img>}
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working

CMDLINE=$(python3 - "$PKG/payload.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6').replace(' sweetfb_noconsole=1', '')
print(cmd)
PY
)
echo "kernel: $KERNEL"
echo "console: on   cpus: $(echo "$CMDLINE" | tr ' ' '\n' | grep cpus=)"

python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c payload.S -o payload.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo BOOT_FOR_KERNEL_OK

#!/bin/bash
# Boot image with the CS-fix kernel (exec_inject clears CS_HARD/CS_RESTRICT).
set -euo pipefail
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.csfix.fuxi
OUT=/mnt/e/DSH-Fuxi/fuxi-csfix.img

CMDLINE=$(python3 - "$PKG/payload.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6').replace(' sweetfb_noconsole=1', '')
cmd = ' '.join(a for a in cmd.split() if not a.startswith(('fuxibbgpu=', 'boot-uuid=', 'fuxiamfi=')))
print(cmd)
PY
)
echo "=== cmdline（控制台开）==="
echo "$CMDLINE" | tr ' ' '\n' | grep -E 'cpus=|noconsole|fuxi' | sed 's/^/  /'

python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c payload.S -o payload.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo CSFIX_BOOT_OK

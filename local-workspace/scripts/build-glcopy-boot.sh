#!/bin/bash
# glcopy=1: force the copy path instead of zero-copy surface sharing.
# If the black areas and the flickering blur go away, the shared path has a
# cache-coherency bug (the GPU writes and the display reads stale memory).
set -euo pipefail
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.csfix.fuxi
OUT=${2:-/mnt/e/DSH-Fuxi/fuxi-csfix-glcopy.img}
EXTRA=${1:-glcopy=1}

CMDLINE=$(python3 - "$PKG/payload.bin" "$EXTRA" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
extra = sys.argv[2]
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6')
drop = ('fuxibbgpu=', 'boot-uuid=', 'fuxiamfi=', 'sweetfb_noconsole=',
        'vblur=', 'glframes=', 'glcensus=', 'glcopy=', 'glwait=')
cmd = ' '.join(a for a in cmd.split() if not a.startswith(drop))
cmd += ' sweetfb_noconsole=1 ' + extra
print(cmd)
PY
)
echo "=== cmdline ==="
echo "$CMDLINE" | tr ' ' '\n' | grep -E 'cpus=|noconsole|gl|vblur' | sed 's/^/  /'

python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c payload.S -o payload.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo BOOT_OK

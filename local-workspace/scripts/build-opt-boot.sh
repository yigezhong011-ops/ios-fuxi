#!/bin/bash
# Optimisation test: raise the GPU level, drop the trace counters.
# Console on so the "FUXI GPU CLOCK"/"ready ... requested kHz" lines are visible.
set -euo pipefail
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.csfix.fuxi
LEVEL=${1:-2}
CONSOLE=${2:-on}
OUT=${3:-/mnt/e/DSH-Fuxi/fuxi-opt-l$LEVEL.img}

CMDLINE=$(python3 - "$PKG/payload.bin" "$LEVEL" "$CONSOLE" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
level, console = sys.argv[2], sys.argv[3]
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6')
drop = ('fuxigpuabi=', 'fuxiperf=', 'fuxigpulevel=', 'sweetfb_noconsole=',
        'fuxibbgpu=', 'boot-uuid=', 'vblur=', 'glcopy=', 'glcensus=')
cmd = ' '.join(a for a in cmd.split() if not a.startswith(drop))
cmd += ' fuxigpulevel=%s' % level
if console != 'on':
    cmd += ' sweetfb_noconsole=1'
print(cmd)
PY
)
echo "=== cmdline ==="
echo "$CMDLINE" | tr ' ' '\n' | grep -E 'cpus=|noconsole|fuxigpu|fuxiperf' | sed 's/^/  /'

python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c payload.S -o payload.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo OPT_OK

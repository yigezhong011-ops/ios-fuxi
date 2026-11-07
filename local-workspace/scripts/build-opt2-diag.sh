#!/bin/bash
# Optimised + diagnostic boot:
#   fuxigpulevel=2      raise the GPU level (level 0 was 220 MHz)
#   no fuxigpuabi/fuxiperf   drop the trace counters
#   no sweetexecswap    let the real peakpowermanagerd run (power/thermal)
#   console on + glcensus=1  the bridge prints its census every 10 s
set -euo pipefail
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.csfix.fuxi
OUT=${1:-/mnt/e/DSH-Fuxi/fuxi-opt2-diag.img}

CMDLINE=$(python3 - "$PKG/payload.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6')
drop_prefix = ('fuxigpuabi=', 'fuxiperf=', 'fuxigpulevel=', 'sweetfb_noconsole=',
               'fuxibbgpu=', 'boot-uuid=', 'vblur=', 'glcopy=', 'glcensus=',
               'glframes=', 'sweetexecswap=', 'serial=', 'sweetsample=', 'sweetscan=',
               'sweetnull=')
parts = [a for a in cmd.split() if not a.startswith(drop_prefix)]
parts += ['fuxigpulevel=2', 'glcensus=1']
print(' '.join(parts))
PY
)
echo "=== cmdline ==="
echo "$CMDLINE" | tr ' ' '\n' | sed 's/^/  /'

python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c payload.S -o payload.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo OPT2_OK

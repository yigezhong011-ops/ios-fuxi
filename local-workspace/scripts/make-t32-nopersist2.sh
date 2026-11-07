#!/bin/bash
# Control for t32-iphone1 (black after the colour bars): the same kernel and arguments, Data from the seed, but t32's own iPad
# identity. Boots -> the iPhone identity is what stops it; black too -> the fresh Data (or this kernel with it) is.
set -euo pipefail
OUT=${1:-t32-nopersist2}
export BLOB_DEFS="-DBACKLIGHT"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho" >/dev/null
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 rm:sheng-data-persist=2 \
  | grep -E 'replaced|zeroed|_OK'

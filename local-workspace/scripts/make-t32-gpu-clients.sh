#!/bin/bash
# t32-gpu<N>: t32-bl-daily (buttons + DSI brightness, no diagnostic page) with a different GPU client list in the addon.
# t32's list is "mediaserverd SpringBoard"; mediaserverd has nothing to do without audio. The kernel's kClientWindows table
# has the render server's window plus two client windows; further listed processes get a device without their own window.
# Usage: make-t32-gpu-clients.sh <out-name> <name,name,...>
set -euo pipefail
OUT=$1; NAMES=$2
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/addon-set-clients.py /root/fuxi/t32/kernel.macho.gpuaddon "/root/fuxi/t32/addon-$OUT" "$NAMES" --same-size
export BLOB_DEFS="-DBACKLIGHT"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho" >/dev/null
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" GPUADDON="/root/fuxi/t32/addon-$OUT" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 \
  | grep -E 'replaced|mismatch|_OK'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/bootimg-sizes.py "/mnt/e/DSH-Fuxi/$OUT.img"

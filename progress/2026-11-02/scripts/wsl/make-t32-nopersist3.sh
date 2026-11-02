#!/bin/bash
# Second control: t32-nopersist2 without the brightness service (buttons only, as t32-buttons-daily2). nopersist2 and
# t32-iphone1 went black after the colour bars; a fresh Data has no saved brightness, so CoreBrightness may start near 0, which the
# DSI backlight now really writes. Desktop here -> the brightness level is the cause, not the fresh Data.
set -euo pipefail
OUT=${1:-t32-nopersist3}
export BLOB_DEFS=""
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho" >/dev/null
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 rm:sheng-data-persist=2 \
  | grep -E 'replaced|zeroed|_OK'

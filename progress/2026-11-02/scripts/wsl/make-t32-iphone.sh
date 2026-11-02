#!/bin/bash
# t32-iphone<N>: t32-bl-daily (buttons + DSI brightness) with pong's identity layout (make-pong-adt-ipados18.py) applied to
# iPhone 15 Pro: hw.product iPhone16,1, /product phone artwork of the 2556 family at scale 3, compatible-device-fallback the same
# model. Unlike t32-phone (iPhone X / D22, which stayed in the iPad layout), the board stays the OS image's own (target-type
# J120), as pong keeps J171 for its jetsam/ABI policy, and /buttons already says no Home button (home-button-type 2).
# Data starts from the payload's seed (no sheng-data-persist=2): no MobileGestalt cache from the iPad identity, and the stored
# Data on userdata is not touched.
# Usage: make-t32-iphone.sh [out-name]
set -euo pipefail
OUT=${1:-t32-iphone1}
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-edit.py /root/fuxi/t32/p.adt "/root/fuxi/t32/$OUT.adt" \
  '/device-tree:model=str:iPhone16,1' \
  '/device-tree/product:product-name=str:iPhone 15 Pro' \
  '/device-tree/product:product-description=str:iPhone 15 Pro' \
  '/device-tree/product:artwork-device-idiom=str:phone' \
  '/device-tree/product:artwork-device-subtype=u32:2556' \
  '/device-tree/product:artwork-scale-factor=u32:3' \
  '/device-tree/product:artwork-dynamic-displaymode=str:0' \
  '/device-tree/product:compatible-device-fallback=str:iPhone16,1' \
  '/device-tree/product:compatible-app-variant=str:0'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/product "/root/fuxi/t32/$OUT.adt" | head -20
export BLOB_DEFS="-DBACKLIGHT"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t32/kernel.macho "/root/fuxi/t32/kernel-$OUT.macho" >/dev/null
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
KERNEL="/root/fuxi/t32/kernel-$OUT.macho" ADT="/root/fuxi/t32/$OUT.adt" bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1 rm:sheng-data-persist=2 \
  | grep -E 'args|replaced|zeroed|_OK'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/bootimg-sizes.py "/mnt/e/DSH-Fuxi/$OUT.img"

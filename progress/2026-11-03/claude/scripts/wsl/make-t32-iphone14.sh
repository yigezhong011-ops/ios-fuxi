#!/bin/bash
# t32-iphone14*: the iPhone identity test again, now on t32-bl-daily's verified kernel (t32-iphone1..4 all used the broken
# post-14:38 blob, so their failure says nothing about the identity). iPhone 14 Pro: hw.product iPhone15,2, phone artwork of
# the 2556 family at scale 3; target-type stays J120 as pong keeps its board's. In-place packing, Data seed intact.
#   PERSIST=0 (default): fresh Data from the payload's seed, so no MobileGestalt cache from the iPad identity
#   PERSIST=1: the stored Data on userdata (its MobileGestalt cache may still answer iPad)
# Usage: make-t32-iphone14.sh <out-name>
set -euo pipefail
OUT=$1
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-edit.py /root/fuxi/t32/p.adt "/root/fuxi/t32/$OUT.adt" \
  '/device-tree:model=str:iPhone15,2' \
  '/device-tree/product:product-name=str:iPhone 14 Pro' \
  '/device-tree/product:product-description=str:iPhone 14 Pro' \
  '/device-tree/product:artwork-device-idiom=str:phone' \
  '/device-tree/product:artwork-device-subtype=u32:2556' \
  '/device-tree/product:artwork-scale-factor=u32:3' \
  '/device-tree/product:compatible-device-fallback=str:iPhone15,2'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-pad-to.py "/root/fuxi/t32/$OUT.adt" "$(stat -c %s /root/fuxi/t32/p.adt)" \
  '/device-tree/product:product-description'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/product "/root/fuxi/t32/$OUT.adt" | head -12
ARGS="rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 add:sheng-backlight=1"
if [ "${PERSIST:-0}" = 1 ]; then ARGS="$ARGS rm:qcom-usb-debug=1"; else ARGS="$ARGS rm:sheng-data-persist=2"; fi
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
export MTOOLS_SKIP_CHECK=1
KERNEL=/root/fuxi/t32/kernel-t32-bl-daily.macho ADT="/root/fuxi/t32/$OUT.adt" \
  bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img "$OUT" $ARGS | grep -E 'replaced|volume|_OK|rror'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/diff-bootimg-vs-vol.py /root/fuxi/t32/vol.img "/mnt/e/DSH-Fuxi/$OUT.img" | grep changed

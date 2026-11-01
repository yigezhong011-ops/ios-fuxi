#!/bin/bash
# Two temp-boot tests on t32-fast's arguments (no diagnostic overlay, GPU scan-out):
#   t32-nopersist : without sheng-data-persist=2, so Data starts from the payload's seed (scratch-data.img, which
#                   holds no MobileGestalt cache) and nothing is kept: does the UI still come up?
#   t32-phone     : the same, plus the iOS identity of docs/guide/mobilegestalt.md (iPhone10,3 / D22 / phone).
#                   The docs pair a phone identity with an iOS root; on this iPadOS root it is an experiment.
set -euo pipefail
FAST="rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 rm:sheng-data-persist=2"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-nopersist $FAST

python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-edit.py /root/fuxi/t32/p.adt /root/fuxi/t32/phone.adt \
  '/device-tree:model=str:iPhone10,3' \
  '/device-tree:target-type=str:D22' \
  '/device-tree/product:product-name=str:iPhone X' \
  '/device-tree/product:product-description=str:iPhone X' \
  '/device-tree/product:artwork-device-idiom=str:phone' \
  '/device-tree/product:artwork-device-subtype=u32:2436' \
  '/device-tree/product:artwork-scale-factor=u32:3' \
  '/device-tree/product:compatible-device-fallback=del' \
  '/device-tree/chosen:display-scale=u32:3'
bash /root/fuxi/show-identity.sh /root/fuxi/t32/phone.adt
ADT=/root/fuxi/t32/phone.adt bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-phone $FAST

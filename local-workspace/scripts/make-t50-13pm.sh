#!/bin/bash
# t50-auto-13pm: the wall17 candidate with the iPhone 13 Pro Max identity, on the stored Data (sheng-data-persist=2 kept). Temp boot only.
# The ADT must keep its size: the longer product name is paid for by a shorter product-description.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-13pm
rm -rf "$W"; mkdir -p "$W"; cp /root/fuxi/t50-wall17/vol.img "$W/vol.img"
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/old.adt"
SIZE=$(stat -c %s "$W/old.adt")
python3 -I $S/adt-edit.py "$W/old.adt" "$W/new.adt" \
  '/device-tree:model=str:iPhone14,3' \
  '/device-tree:target-type=str:D64' \
  '/device-tree/product:product-name=str:iPhone 13 Pro Max' \
  '/device-tree/product:product-description=str:iPhone 13PM' \
  '/device-tree/product:artwork-device-subtype=u32:2778'
python3 -I $S/adt-pad-to.py "$W/new.adt" "$SIZE" '/device-tree/product:product-description'
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/new.adt" >/dev/null
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/check.adt"
cmp "$W/check.adt" "$W/new.adt" && echo 'adt in volume ok'
for n in /device-tree /device-tree/product; do python3 -I $S/adt-node-props.py $n "$W/check.adt" | grep -E ' (model|target-type|product-name|product-description|artwork-device-subtype) ' | cut -c1-90; done
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 300 t50-auto-13pm
mtype -i /root/fuxi/auto-t50-auto-13pm/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o 'sheng-data-persist=[0-9]'

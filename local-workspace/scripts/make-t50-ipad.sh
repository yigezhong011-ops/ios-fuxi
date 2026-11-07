#!/bin/bash
# t50-auto-ipad: the wall17 candidate back on the iPad identity of make-fuxi-adt.py (iPad7,1, J120, pad, 2732, scale 2, sRGB, fallback iPad6,7) with unit scale 2.
# Needs a reset Data store: MobileGestalt keeps the first identity. Temp boot only; writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-ipad; N='iPad Pro (12.9-inch) (2nd generation)'
rm -rf "$W"; mkdir -p "$W"; cp /root/fuxi/t50-wall17/vol.img "$W/vol.img"
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/old.adt"
python3 -I $S/adt-edit.py "$W/old.adt" "$W/new.adt" \
  '/device-tree:model=str:iPad7,1' \
  '/device-tree:target-type=str:J120' \
  "/device-tree/product:product-name=str:$N" \
  "/device-tree/product:product-description=str:$N" \
  '/device-tree/product:artwork-device-idiom=str:pad' \
  '/device-tree/product:artwork-device-subtype=u32:2732' \
  '/device-tree/product:artwork-scale-factor=u32:2' \
  '/device-tree/product:artwork-display-gamut=str:sRGB' \
  '/device-tree/product:compatible-device-fallback=str:iPad6,7'
stat -c 'new adt %s bytes' "$W/new.adt"
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/new.adt" --grow >/dev/null
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/check.adt"
cmp "$W/check.adt" "$W/new.adt" && echo 'adt in volume ok'
for n in /device-tree /device-tree/product; do python3 -I $S/adt-node-props.py $n "$W/check.adt" | grep -E ' (model|target-type|product-name|artwork-[a-z-]+|compatible-device-fallback) ' | cut -c1-90; done
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
sed 's/offline-legacy-unit-scale=3/offline-legacy-unit-scale=2/' "$W/toml.orig" > "$W/toml"
cmp -s "$W/toml.orig" "$W/toml" && { echo 'scale not changed'; exit 1; }
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" >/dev/null
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-ipad
mtype -i /root/fuxi/auto-t50-auto-ipad/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'offline-legacy-unit-scale=[0-9]|sheng-setup=[0-9]|sheng-data-persist=[0-9]|sheng-autoreset=[0-9]+' | tr '\n' ' '; echo

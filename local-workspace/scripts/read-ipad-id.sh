#!/bin/bash
# Read-only: the working iPad image's identity and scale against the candidate's, and how the wallpaper overlay would look to an iPad.
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl
for a in /root/fuxi/t32/p.adt; do
  [ -f "$a" ] || continue
  echo "== $a $(stat -c %s $a)"
  for n in /device-tree /device-tree/product /device-tree/buttons; do python3 -I $S/adt-node-props.py $n $a | grep -E ' (model|target-type|product-name|product-description|artwork-[a-z-]+|compatible-device-fallback|thin-bezel|home-button-type|button-names) ' | cut -c1-90; done
done
echo "== t32 args"
mtype -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'offline-legacy-unit-scale=[0-9]|sheng-setup=[0-9]|sheng-data-persist=[0-9]'
echo "== candidate"
mcopy -n -i /root/fuxi/t50-wall17/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt /tmp/c.adt
python3 -I $S/adt-node-props.py /device-tree/product /tmp/c.adt | cut -c1-80
python3 -I $S/adt-node-props.py /device-tree /tmp/c.adt | cut -c1-80 | head -12
rm -f /tmp/c.adt
echo "== fat-inplace rule"; grep -n -E 'size|len\(' $S/fat-inplace.py | cut -c1-130 | head -12
echo "== overlay files in the candidate addon"
sed -n 1,30p $S/make-t50-wallcat.sh | grep -n -E 'Collections|ipad|iphone|CATALOG|plist' | cut -c1-170

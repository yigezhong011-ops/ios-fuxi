#!/bin/bash
# t50-auto-iphonex: the wall17 candidate with the iPhone X identity (iPhone10,3, D22, subtype 2436) to test the red bar.
# Without sheng-data-persist the store window stays closed (NativeUfs storeMode 0), so Data is the seed in RAM: the stored Data is not written
# and no old MobileGestalt cache answers. Temp boot only; writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; B=/root/fuxi/t50-wall17; W=/root/fuxi/t50-ipx
rm -rf "$W"; mkdir -p "$W"; cp "$B/vol.img" "$W/vol.img"
echo "== hard-coded identity in the kernel and addon"
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon "$W/addon"
for f in "$B/kernel.macho" "$W/addon"; do printf '%s: ' "$(basename $f)"; grep -a -c -E 'iPhone15,2|iPhone 14 Pro|D72' "$f" || true; done
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/old.adt"
SIZE=$(stat -c %s "$W/old.adt")
python3 -I $S/adt-edit.py "$W/old.adt" "$W/new.adt" \
  '/device-tree:model=str:iPhone10,3' \
  '/device-tree:target-type=str:D22' \
  '/device-tree/product:product-name=str:iPhone X' \
  '/device-tree/product:product-description=str:iPhone X' \
  '/device-tree/product:artwork-device-subtype=u32:2436'
python3 -I $S/adt-pad-to.py "$W/new.adt" "$SIZE" '/device-tree/product:product-description'
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/new.adt" >/dev/null
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 -I - "$W/toml.orig" "$W/toml" <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
args.remove('sheng-data-persist=2')
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
body = new.rstrip(b'\n ')
open(sys.argv[2], 'wb').write(body + b'\n' + b' ' * (len(old) - len(body) - 1))
PY
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" >/dev/null
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/check.adt"
cmp "$W/check.adt" "$W/new.adt" && echo 'adt in volume ok'
for n in /device-tree /device-tree/product; do python3 -I $S/adt-node-props.py $n "$W/check.adt" | grep -E ' (model|target-type|product-name|product-description|artwork-device-idiom|artwork-device-subtype|artwork-scale-factor) ' | cut -c1-90; done
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 300 t50-auto-iphonex
mtype -i /root/fuxi/auto-t50-auto-iphonex/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -c 'sheng-data-persist' || true
ls -la $E/t50-auto-iphonex.img | cut -c24-

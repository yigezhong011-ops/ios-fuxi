#!/bin/bash
# t50-auto-scale2: the wall17 candidate (14 Pro identity, wallpaper fix) with only offline-legacy-unit-scale 3 -> 2. The ADT is untouched. Temp boot only; writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-scale2
rm -rf "$W"; mkdir -p "$W"; cp /root/fuxi/t50-wall17/vol.img "$W/vol.img"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
echo 'scale args before:'; grep -a -o -E '[a-z-]*scale[a-z-]*=[0-9]+' "$W/toml.orig" | sort -u
[ "$(grep -a -c 'offline-legacy-unit-scale=3' "$W/toml.orig")" -ge 1 ]
sed 's/offline-legacy-unit-scale=3/offline-legacy-unit-scale=2/' "$W/toml.orig" > "$W/toml"
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" >/dev/null
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-scale2
echo 'final args:'; mtype -i /root/fuxi/auto-t50-auto-scale2/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'offline-legacy-unit-scale=[0-9]|sheng-setup=[0-9]|sheng-data-persist=[0-9]|sheng-autoreset=[0-9]+' | tr '\n' ' '; echo

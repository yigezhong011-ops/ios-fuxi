#!/bin/bash
# Read the upstream fixes for colour, widgets and wallpaper; dry-apply the newer GMEM patch on the pinned Mesa. Touches no image.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
A=/root/fuxi/src-adrenometal; PIN=7e0d3d2ebaecd736784de0baa09254b7f63bc150
U=/root/fuxi/src-unixnu
[ -d "$U/.git" ] || git clone -q --filter=blob:none --no-checkout https://github.com/UniXNU/UniXNU.git "$U"
git -C "$U" fetch -q origin
R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
echo "== make-gpu-addon.py wallpaper at 793d"
git -C "$U" show $R:scripts/make-gpu-addon.py | sed -n 1,20p | cut -c1-220
git -C "$U" show $R:scripts/make-gpu-addon.py | grep -n -i -E 'wallpaper|poster' | cut -c1-200
echo "== UniXNU commits on the GMEM patches"
for p in turnip-gmem-memory-side-swap turnip-transient-attachments-in-gmem turnip-gmem-swap-trace; do
  git -C "$U" log --reverse --format="$p %h %cI %s" -1 --diff-filter=A origin/main -- patches/mesa/$p.patch | cut -c1-150
done
echo "== memory-side-swap patch head"
git -C "$U" show origin/main:patches/mesa/turnip-gmem-memory-side-swap.patch | sed -n 1,70p | cut -c1-150
echo "== upstream notes on widgets / wallpaper / poster after the pin"
git -C "$A" log --format='%h %cI %s' $PIN..origin/HEAD -i --grep='widget\|poster\|wallpaper\|client slot\|fourth client\|slots' | cut -c1-130 | head -20
git -C "$U" log --format='%h %cI %s' $R..origin/main -i --grep='widget\|poster\|wallpaper\|client slot\|gpu client' | cut -c1-130 | head -20
echo "== slot limit in Adreno740 at pinned driver"
D=/root/fuxi/src-adreno740; [ -d "$D/.git" ] || git clone -q --filter=blob:none --no-checkout https://github.com/UniXNU/Adreno740.git "$D"
git -C "$D" fetch -q origin; DP=759d646eca12fc202d1c228c5fa5d3c6c01a0aa3
git -C "$D" grep -n -i -E 'kMaxClient|MaxClients|client slot|slots\[|kClientWindows' $DP | sed "s/^$DP://" | cut -c1-170 | head -15
echo "== dry-apply on pinned Mesa"
M=/root/fuxi/src-mesa-pin
if [ ! -d "$M/.git" ]; then
  git -C "$U" show $R:scripts/data/adreno-compiler-inputs.json > /tmp/pins.json
  read -r REPO C < <(python3 -c 'import json; m=json.load(open("/tmp/pins.json"))["mesa"]; print(m.get("mirror", m["repository"]), m["commit"])')
  echo "mesa $REPO $C"; git init -q "$M"; git -C "$M" fetch -q --depth=1 "$REPO" "$C"; git -C "$M" checkout -q --detach FETCH_HEAD
fi
git -C "$M" reset -q --hard; git -C "$M" clean -qfd
git -C "$U" show $R:scripts/data/adreno-compiler-inputs.json > /tmp/pins.json
for p in $(python3 -c 'import json; print(" ".join(json.load(open("/tmp/pins.json"))["patches"]))'); do
  git -C "$U" show $R:$p | git -C "$M" apply - && echo "ok  $p" || echo "BAD $p"
done
for p in turnip-gmem-memory-side-swap; do
  git -C "$U" show origin/main:patches/mesa/$p.patch > /tmp/$p.patch
  git -C "$M" apply --check /tmp/$p.patch && echo "CAN APPLY $p" || echo "CANNOT APPLY $p"
done
git -C "$U" show origin/main:scripts/data/adreno-compiler-inputs.json > /tmp/pins-main.json
python3 -c 'import json; print(json.load(open("/tmp/pins-main.json"))["patches"])' | cut -c1-900
git -C "$M" reset -q --hard; git -C "$M" clean -qfd

#!/bin/bash
# Check the leads on our own image and tree: wallpaper assets per idiom, the GPU client lists, and the store failure's site. Read-only.
E=/mnt/e/DSH-Fuxi; P=$E/dump/root-peek; B=$E/unixnu-build/fuxi
ls -la $P | cut -c1-90 | head -14
echo "== wallpaper collections in our System image"
if command -v 7z >/dev/null; then
  7z l -ba "$P/systemos.img" 2>/dev/null | grep -E 'Library/Wallpaper/Collections' | awk '{print $NF}' | awk -F/ '{for(i=1;i<=NF;i++) if($i ~ /wallpaperCollection$/) print $i}' | sort | uniq -c | head -20
  echo "-- wallpapers by suffix"
  7z l -ba "$P/systemos.img" 2>/dev/null | grep -E '\.wallpaper$|\.wallpaper/' | grep -o -E '[^/]+\.wallpaper' | sort -u | sed -E 's/.*(~[a-z]+)\.wallpaper/\1/' | sort | uniq -c | head
  echo "-- poster extensions"
  7z l -ba "$P/systemos.img" 2>/dev/null | grep -o -E '[A-Za-z]*Poster[A-Za-z]*\.appex' | sort -u | head -24
else echo "no 7z"; fi
echo "== client lists in our tree"
grep -n -E 'NativeSandboxGrantProcess' -r $B/package 2>/dev/null | cut -c1-190 | head
grep -n -r -E -- '--clients|sheng-gpu-clients|clients *=' $B/board.toml $B/scripts $B/../fuxi/AGENTS.md 2>/dev/null | cut -c1-190 | head -8
grep -n -r -E 'phone_model|phone-identity|fuxi-backlight' $B/board.toml 2>/dev/null | cut -c1-150 | head
echo "== client list in the running addon"
strings -n 6 $E/dump/wsl/addons/NativeAdrenoMetal.fillerx 2>/dev/null | head -0
ls $E/dump/wsl/addons 2>/dev/null | head
echo "== upstream head: who gets the GPU"
git -C /root/fuxi/src-unixnu log --format='%h %ad %s' --date=short -3 --grep='grant the gpu user client'
git -C /root/fuxi/src-unixnu show 0ca54a3 --format= 2>/dev/null | grep -E '^\+' | grep -i -E 'grant|client|Poster|list' | cut -c1-170 | head -14
echo "== store failure site"
sed -n '1,16p' $E/dump/wsl/read-dsc-xref.py | cut -c1-170
for f in $E/dump/wsl/run-dsc*.sh; do echo "-- $f"; cut -c1-170 "$f" | head -10; done
echo "== poster failure background job"
pgrep -af 'python3' | cut -c1-90 | head

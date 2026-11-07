#!/bin/bash
# The store failure's branch, the catalog lookup, and how the kernel mounts the overlay. Read-only.
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; D=$E/dump/root-peek/dsc; B=$E/unixnu-build/fuxi
echo "== mount code"
sed -n '250,335p' $B/patches/xnu/zzy-native-gpu-addon-mount.patch | cut -c1-185
echo "== catalog names in our image"
grep -a -E 'Wallpaper/Collections/[^/ ]*\.plist|Wallpaper/Collections/[^/]+/[^/ ]*\.plist$' $E/dump/root-peek/list.txt | cut -c1-150 | head
echo "== catalog strings in the dyld cache"
cd "$D" && LC_ALL=C grep -a -l 'Collections~' dyld_shared_cache_arm64* 2>/dev/null | head
for f in dyld_shared_cache_arm64*; do LC_ALL=C grep -a -o -E '[ -~]{0,50}(Collections~|wallpaperCollection|Collections\.plist)[ -~]{0,50}' "$f" 2>/dev/null; done | sort | uniq -c | sort -rn | head -14 | cut -c1-140
echo "== store failure branch"
cd $S
python3 -I read-dsc-xref.py $D d 0x1ca9149c8 160 60 2>&1 | grep -E ' ; |^==|cbz|cbnz|tbz|tbnz|ret|bl ' | cut -c1-140 | tail -60

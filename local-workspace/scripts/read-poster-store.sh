#!/bin/bash
# Read-only: what PosterBoard's data store, the wallpaper overlay and the migration plist look like on the Data copy.
A="python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py /mnt/e/DSH-Fuxi/logs/data-raw.img"
C=mobile/Containers/Data/Application/353FB615-9AD2-407D-B79C-EFF255D5432B
echo "== root"; $A ls 0 / | head -30
for p in "$C/Library/Application Support/PRBPosterExtensionDataStore" "$C/Library/Application Support/PRBPosterExtensionDataStore/61" "$C/Library/Application Support" "$C/Library" ngpu ngpu/wallpaper; do
  echo "== $p"; $A ls 0 "$p" 2>&1 | cut -c1-140 | head -40
done
echo "== container meta"; $A ls 0 "$C" 2>&1 | cut -c1-140 | head
echo "== migration"; $A ls 0 mobile/Library/Preferences 2>&1 | grep -E 'migration|PosterBoard|springboard|mobile.wallpaper|PaperBoard' | cut -c1-120
$A ls 0 root/Library/Preferences 2>&1 | grep -E 'migration' | cut -c1-120
$A ls 0 preferences/SystemConfiguration 2>&1 | head -3 | cut -c1-100
$A stat 0 root/Library/Preferences/com.apple.migration.plist 2>&1 | cut -c1-200

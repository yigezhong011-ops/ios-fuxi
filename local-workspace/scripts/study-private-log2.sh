#!/bin/bash
# Read-only: root layout for the Logging preference paths, and the overlay mount code in the kernel patches.
R=/mnt/e/DSH-Fuxi/dump/root-peek
wc -l $R/list.txt $R/sys-list.txt
for f in $R/list.txt $R/sys-list.txt; do echo "-- $f"; grep -n -E '(^|[ /])Library/Preferences($|/Logging| )|Preferences/Logging/[^/]*$|/Library/Managed|ManagedPreferences' $f | cut -c1-140 | head -16; grep -c 'Preferences/Logging/Subsystems' $f; grep -E 'Logging/Subsystems/.*(Poster|chrono|Chrono)' $f | cut -c1-140 | head; done
echo "== mount patch"
for d in /root/fuxi/fuxi2 /root/fuxi/ux-device /root/fuxi/fork-device; do
  P=$(grep -rIl -E 'ngpu/wallpaper|WALLPAPER stage' $d --include='*' 2>/dev/null | grep -v '\.git/' | head -5); echo "$d: $P"
done
P=$(grep -rIl 'WALLPAPER stage' /root/fuxi/fuxi2 2>/dev/null | head -1); echo "using $P"
if [ -n "$P" ]; then grep -n -E 'WALLPAPER|ngpu/wallpaper|wallpaper_|vfs_mount|mount\(|bindfs|nullfs|union' "$P" | cut -c1-170 | head -40; fi

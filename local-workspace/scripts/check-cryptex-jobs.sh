#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/cryptex
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
echo "=== /System/Cryptexes 结构 ==="
ls "$M/System/Cryptexes" 2>/dev/null
echo
echo "=== cryptex 里的 bluetoothd plist ==="
find "$M/System/Cryptexes" -maxdepth 6 -name 'com.apple.bluetoothd.plist*' 2>/dev/null | head -5
echo
echo "=== cryptex 里的 launchd.plist ==="
find "$M/System/Cryptexes" -maxdepth 6 -name 'launchd.plist' 2>/dev/null | head -5
echo
echo "=== root 的 plist 现状（应已改名）==="
ls "$M/System/Library/LaunchDaemons/" 2>/dev/null | grep -E 'bluetoothd|fairplayd|driverkitd' | head -6
umount "$M" 2>/dev/null || true

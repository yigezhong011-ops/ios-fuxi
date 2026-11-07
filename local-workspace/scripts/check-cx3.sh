#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/cx3
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
D="$M/private/preboot/Cryptexes/OS/System/Library/LaunchDaemons"
echo "=== cryptex LaunchDaemons 目录 ==="
ls "$D" 2>/dev/null | head -5
echo "条目数: $(ls "$D" 2>/dev/null | wc -l)"
echo
echo "=== 该目录里的 bluetooth/fairplay/driverkit ==="
ls "$D" 2>/dev/null | grep -E 'bluetoothd|fairplayd|driverkitd' || echo "(无)"
echo
echo "=== root 的 LaunchDaemons 条目数 ==="
ls "$M/System/Library/LaunchDaemons" 2>/dev/null | wc -l
umount "$M" 2>/dev/null || true

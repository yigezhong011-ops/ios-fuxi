#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/cx2
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
echo "=== /System/Cryptexes/OS 是什么 ==="
ls -la "$M/System/Cryptexes/" 2>/dev/null | head -6
file "$M/System/Cryptexes/OS" 2>/dev/null
ls "$M/System/Cryptexes/OS/" 2>/dev/null | head -8
echo
echo "=== 是否有 dyld 缓存/系统库指向 cryptex ==="
ls -la "$M/System/Library/dyld" 2>/dev/null | head -5
echo
echo "=== 整个镜像里 bluetoothd.plist 的所有副本 ==="
timeout 200 find "$M" -name 'com.apple.bluetoothd.plist' 2>/dev/null | head -5
umount "$M" 2>/dev/null || true

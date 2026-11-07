#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/check3
mkdir -p "$M"
mount -o loop,ro "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
CAR="$M/System/Library/PrivateFrameworks/UIKitCore.framework/BoundingPathData.bundle/Assets.car"
echo "=== 资产库里所有 BoundingPathBitmap 名字 ==="
strings "$CAR" 2>/dev/null | grep -o 'BoundingPathBitmap-[0-9x.-]*' | sort -u | head -20
echo
echo "=== 是否有 1080x2400 ==="
strings "$CAR" 2>/dev/null | grep -c 'BoundingPathBitmap-1080x2400' || true
umount "$M" 2>/dev/null || true

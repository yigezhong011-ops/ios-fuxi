#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/check2
mkdir -p "$M"
mount -o loop,ro "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
echo "=== 搜索 BoundingPathBitmap 资产名 ==="
grep -rl 'BoundingPathBitmap-1125x2436' "$M/System/Library/PrivateFrameworks/UIKitCore.framework/" 2>/dev/null | head -3
echo "--- 直接 strings 找 ---"
for f in "$M"/System/Library/PrivateFrameworks/UIKitCore.framework/Assets.car \
         "$M"/System/Library/PrivateFrameworks/UIKitCore.framework/*.car; do
  [ -f "$f" ] || continue
  n=$(strings "$f" 2>/dev/null | grep -c 'BoundingPathBitmap')
  echo "$(basename "$f"): $n 个 BoundingPathBitmap"
done
echo
echo "=== 找所有含 BoundingPathBitmap 的文件 ==="
timeout 240 grep -rl 'BoundingPathBitmap' "$M/System/Library" 2>/dev/null | head -5
umount "$M" 2>/dev/null || true

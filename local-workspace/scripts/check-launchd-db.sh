#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/launchddb
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
echo "=== launchd 持久化数据库 ==="
ls -la "$M/private/var/db/com.apple.xpc.launchd" 2>/dev/null | head -10
echo
echo "=== 其他可能的缓存 ==="
find "$M/private/var/db" -maxdepth 2 -iname '*launchd*' 2>/dev/null | head -8
echo
echo "=== 数据库里是否有 bluetoothd ==="
for f in "$M"/private/var/db/com.apple.xpc.launchd/*; do
  [ -f "$f" ] || continue
  if strings "$f" 2>/dev/null | grep -q 'com.apple.bluetoothd'; then
    echo "命中: $f"
  fi
done
umount "$M" 2>/dev/null || true

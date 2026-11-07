#!/bin/bash
set -euo pipefail
echo "=== /dev/fuse ==="
ls -l /dev/fuse || echo "NO /dev/fuse"
mkdir -p /root/fuxi/mnt/os
echo "=== 挂载 OS dmg (4.5G) ==="
timeout 300 /root/apfs-fuse/build/apfs-fuse -d 0 /root/fuxi/ipsw/087-86698-044.dmg /root/fuxi/mnt/os 2>&1 | tail -15
echo "=== 内容 ==="
ls /root/fuxi/mnt/os 2>&1 | head
echo "=== volume 根 ==="
ls /root/fuxi/mnt/os/root 2>&1 | head -20
echo "=== SystemVersion ==="
head -c 400 /root/fuxi/mnt/os/root/System/Library/CoreServices/SystemVersion.plist 2>&1 || true
echo
echo "MOUNT_TEST_DONE"

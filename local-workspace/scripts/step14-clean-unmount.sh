#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/iosroot.img
mkdir -p /root/fuxi/mnt/root
mount -t hfsplus -o loop,force "$IMG" /root/fuxi/mnt/root && echo "mounted rw"
touch /root/fuxi/mnt/root/.probe && rm -f /root/fuxi/mnt/root/.probe && echo "write ok"
sync
umount /root/fuxi/mnt/root && echo "unmounted cleanly"
echo "=== verify after clean unmount ==="
fsck.hfsplus -f -n "$IMG" 2>&1 | tail -4
echo "=== repair once more ==="
fsck.hfsplus -f -y "$IMG" 2>&1 | grep -v 'Illegal name' | tail -3
fsck.hfsplus -f -n "$IMG" 2>&1 | tail -3
echo DONE

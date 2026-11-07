#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/tweak2
mkdir -p "$M"
echo "=== fsck ==="
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -2
echo "=== 挂载 ==="
mount -t hfsplus -o loop,rw,force "$IMG" "$M" 2>&1 || { echo MOUNT_FAILED; exit 1; }
echo "=== 应用 tweaks ==="
cd /root/ios-fuxi
python3 tools/sweet-root-tweaks.py "$M" 2>&1 | tail -25
echo "=== 卸载 ==="
sync
umount "$M" && echo UNMOUNTED

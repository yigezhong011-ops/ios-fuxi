#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-1616.img
M=/root/fuxi/mnt/wallimg
mkdir -p "$M"
mount -t hfsplus -o loop,rw,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
cd /root/ios-fuxi
python3 tools/sweet-root-tweaks.py --legacy-wallpaper-image --only-optional "$M" 2>&1 | tail -8
echo "=== 确认 cpbitmap 存在 ==="
ls -l "$M/private/var/mobile/Library/SpringBoard/"*.cpbitmap 2>/dev/null | head -3
sync
umount "$M" && echo UNMOUNTED

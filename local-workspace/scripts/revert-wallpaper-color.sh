#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-1616.img
M=/root/fuxi/mnt/wallrev
mkdir -p "$M"
[ -f "$IMG" ] || { echo "缺 root 镜像"; exit 1; }
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
mount -t hfsplus -o loop,rw,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
cd /root/ios-fuxi
python3 tools/sweet-root-tweaks.py --no-legacy-wallpaper-color --only-optional "$M" 2>&1 | tail -6
sync
umount "$M" && echo UNMOUNTED

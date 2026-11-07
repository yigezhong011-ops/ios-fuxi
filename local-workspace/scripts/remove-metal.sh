#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-1616.img
MNT=/root/fuxi/mnt/nometal
mkdir -p "$MNT"
mount -t hfsplus -o loop,rw,force "$IMG" "$MNT" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
rm -rf "$MNT/System/Library/Extensions/FuxiMetal.bundle"
rm -f "$MNT/usr/local/lib/libmetal2vulkan.dylib"
rm -f "$MNT/usr/local/share/fuxi/metal-clients.conf"
echo "=== 壁纸仍在？ ==="
ls -l "$MNT/private/var/mobile/Library/SpringBoard/"*.cpbitmap 2>/dev/null | head -2
sync
umount "$MNT"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo NOMETAL_OK

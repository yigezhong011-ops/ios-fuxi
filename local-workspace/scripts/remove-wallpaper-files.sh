#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-clean.img
M=/root/fuxi/mnt/wallfix
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$M"
cd /root/ios-fuxi
echo "=== 删除壁纸文件，回到系统默认回退 ==="
python3 tools/sweet-root-tweaks.py --no-legacy-wallpaper-image --only-optional "$M" 2>&1 | tail -4
python3 tools/sweet-root-tweaks.py --no-legacy-wallpaper-color --only-optional "$M" 2>&1 | tail -3
echo "=== 确认 SpringBoard 目录 ==="
ls -l "$M/private/var/mobile/Library/SpringBoard/" 2>/dev/null | head -5
sync
umount "$M"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo WALLFIX_OK

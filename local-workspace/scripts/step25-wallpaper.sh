#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/wall.log) 2>&1

echo "=== 复制镜像到 ext4（环回挂载更快）==="
date
cp /mnt/e/DSH-Fuxi/dump/iosroot-sys.img /root/fuxi/base.img
ls -lh /root/fuxi/base.img

for m in $(mount | awk '/hfsplus/{print $3}' | sort -r); do umount -l "$m" 2>/dev/null || true; done
mkdir -p /root/fuxi/mnt/wall
mount -t hfsplus -o loop,force,rw /root/fuxi/base.img /root/fuxi/mnt/wall
R=/root/fuxi/mnt/wall

echo "=== 应用 legacy 壁纸 ==="
cd /root/ios-fuxi
python3 tools/sweet-root-tweaks.py --legacy-wallpaper --legacy-wallpaper-color '#2e3a6e' "$R" 2>&1 | tail -12

echo "=== 卸载 + fsck ==="
sync
umount "$R"
fsck.hfsplus -f -y /root/fuxi/base.img 2>&1 | grep -v 'Illegal name' | tail -2 || true

echo "=== 拷回 E 盘 ==="
cp /root/fuxi/base.img /mnt/e/DSH-Fuxi/dump/iosroot-wall.img
ls -lh /mnt/e/DSH-Fuxi/dump/iosroot-wall.img
echo WALL_IMAGE_OK

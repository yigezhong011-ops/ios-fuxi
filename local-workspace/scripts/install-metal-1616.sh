#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-1616.img
MNT=/root/fuxi/mnt/metal2
SRC=/mnt/e/DSH-Fuxi/ci/metal
mkdir -p "$MNT"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$MNT"

echo "=== FuxiMetal.bundle ==="
mkdir -p "$MNT/System/Library/Extensions"
rm -rf "$MNT/System/Library/Extensions/FuxiMetal.bundle"
cp -R "$SRC/FuxiMetal.bundle" "$MNT/System/Library/Extensions/FuxiMetal.bundle"
chown -R 0:0 "$MNT/System/Library/Extensions/FuxiMetal.bundle"
find "$MNT/System/Library/Extensions/FuxiMetal.bundle" -type f -exec chmod 644 {} \;
chmod 755 "$MNT/System/Library/Extensions/FuxiMetal.bundle/FuxiMetal"

echo "=== libmetal2vulkan.dylib ==="
mkdir -p "$MNT/usr/local/lib"
cp "$SRC/libmetal2vulkan.dylib" "$MNT/usr/local/lib/libmetal2vulkan.dylib"
chown 0:0 "$MNT/usr/local/lib/libmetal2vulkan.dylib"
chmod 755 "$MNT/usr/local/lib/libmetal2vulkan.dylib"

echo "=== metal-clients.conf ==="
mkdir -p "$MNT/usr/local/share/fuxi"
cp "$SRC/metal-clients.conf" "$MNT/usr/local/share/fuxi/metal-clients.conf"
chown 0:0 "$MNT/usr/local/share/fuxi/metal-clients.conf"
chmod 644 "$MNT/usr/local/share/fuxi/metal-clients.conf"

echo "=== 结果 ==="
ls -l "$MNT/System/Library/Extensions/FuxiMetal.bundle" | head -6
ls -l "$MNT/usr/local/lib/libmetal2vulkan.dylib"
sync
umount "$MNT"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo METAL_IMAGE_OK

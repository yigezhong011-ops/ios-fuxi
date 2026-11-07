#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/metal-install.log) 2>&1

IMG=/root/fuxi/base.img
MNT=/root/fuxi/mnt/metal
SRC=/mnt/e/DSH-Fuxi/ci/metal
mkdir -p "$MNT"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$MNT"

echo "=== 安装 FuxiMetal.bundle ==="
mkdir -p "$MNT/System/Library/Extensions"
rm -rf "$MNT/System/Library/Extensions/FuxiMetal.bundle"
cp -R "$SRC/FuxiMetal.bundle" "$MNT/System/Library/Extensions/FuxiMetal.bundle"
chown -R 0:0 "$MNT/System/Library/Extensions/FuxiMetal.bundle"
chmod 755 "$MNT/System/Library/Extensions/FuxiMetal.bundle/FuxiMetal"
chmod 644 "$MNT/System/Library/Extensions/FuxiMetal.bundle/Info.plist"
chmod 644 "$MNT/System/Library/Extensions/FuxiMetal.bundle/_CodeSignature/CodeResources"

echo "=== 安装 libmetal2vulkan.dylib ==="
mkdir -p "$MNT/usr/local/lib"
cp "$SRC/libmetal2vulkan.dylib" "$MNT/usr/local/lib/libmetal2vulkan.dylib"
chown 0:0 "$MNT/usr/local/lib/libmetal2vulkan.dylib"
chmod 755 "$MNT/usr/local/lib/libmetal2vulkan.dylib"

echo "=== 安装 metal-clients.conf ==="
mkdir -p "$MNT/usr/local/share/fuxi"
cp "$SRC/metal-clients.conf" "$MNT/usr/local/share/fuxi/metal-clients.conf"
chown 0:0 "$MNT/usr/local/share/fuxi/metal-clients.conf"
chmod 644 "$MNT/usr/local/share/fuxi/metal-clients.conf"

echo "=== 结果 ==="
ls -lR "$MNT/System/Library/Extensions/FuxiMetal.bundle" | head -10
ls -l "$MNT/usr/local/lib/libmetal2vulkan.dylib" "$MNT/usr/local/share/fuxi/metal-clients.conf"

sync
umount "$MNT"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
rm -f /mnt/e/DSH-Fuxi/dump/iosroot-nolock.img
dd if="$IMG" of=/mnt/e/DSH-Fuxi/dump/iosroot-metal.img bs=8M conv=sparse status=none
ls -lh /mnt/e/DSH-Fuxi/dump/iosroot-metal.img
echo METAL_IMAGE_OK

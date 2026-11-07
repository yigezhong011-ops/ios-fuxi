#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-clean.img
M=/root/fuxi/mnt/nometal2
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$M"
echo "=== 移除 metal 组件 ==="
rm -rf "$M/System/Library/Extensions/FuxiMetal.bundle"
rm -f "$M/usr/local/lib/libmetal2vulkan.dylib" "$M/usr/local/lib/libvulkan_freedreno.dylib"
rm -f "$M/usr/local/share/fuxi/metal-clients.conf" "$M/usr/local/share/fuxi/metal-smoke.conf" "$M/usr/local/share/fuxi/ca-smoke.conf"
rm -rf "$M/private/var/db/fuxi-metal"
echo "=== 保留 ==="
ls "$M/System/Library/Extensions/" | head -5
echo "=== 壁纸文件状态 ==="
ls -la "$M/private/var/mobile/Library/SpringBoard/" 2>/dev/null | head -5 || echo "(目录为空/不存在 = 系统回退黑底)"
sync
umount "$M"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo NOMETAL2_OK

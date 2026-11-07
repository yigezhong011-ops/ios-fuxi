#!/bin/bash
set -uo pipefail
RAW=/root/fuxi/root6.raw
[ -f "$RAW" ] || { echo "root6.raw 已删除，跳过"; exit 0; }
M=/root/fuxi/mnt/verify6
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,ro,force "$RAW" "$M"
echo "=== 插件 ==="
ls -l "$M/System/Library/Extensions/FuxiMetal.bundle/" 2>/dev/null
echo "=== ICD 与翻译层 ==="
ls -l "$M/usr/local/lib/libvulkan_freedreno.dylib" "$M/usr/local/lib/libmetal2vulkan.dylib" 2>/dev/null
echo "=== 客户端列表（应含 backboardd）==="
grep -v '^#' "$M/usr/local/share/fuxi/metal-clients.conf" 2>/dev/null
echo "=== backboardd 私有存储 ==="
ls -ld "$M/private/var/db/fuxi-metal"/* 2>/dev/null
echo "=== 卷头 ==="
xxd -l 16 -s 1024 "$RAW" | head -1
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

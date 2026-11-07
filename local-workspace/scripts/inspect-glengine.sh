#!/bin/bash
set -uo pipefail
RAW=/root/fuxi/root8.raw
M=/root/fuxi/mnt/root8
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,ro,force "$RAW" "$M"

echo "=== GLEngine.bundle 内容 ==="
ls -lR "$M/System/Library/Frameworks/OpenGLES.framework/GLEngine.bundle/" 2>/dev/null | head -25
echo
echo "=== Info.plist ==="
cat "$M/System/Library/Frameworks/OpenGLES.framework/Info.plist" 2>/dev/null | head -30
echo
echo "=== 共享缓存 ==="
ls -l "$M/System/Library/Caches/com.apple.dyld/" 2>/dev/null | head -10
echo
echo "=== 共享缓存里有没有 GLESv2 ==="
grep -c 'libGLESv2' "$M/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64" 2>/dev/null || echo "（grep 不可用或文件很大）"
sync
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

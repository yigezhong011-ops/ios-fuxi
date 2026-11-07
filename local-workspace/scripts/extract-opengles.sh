#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
RAW=/root/fuxi/verify-root.raw
if [ ! -f "$RAW" ]; then
  echo "=== 转换稀疏镜像（约 5 分钟）==="
  simg2img "$P/ios16-root-v11-fixed.simg" "$RAW"
fi
ls -lh "$RAW"
M=/root/fuxi/mnt/verify
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,ro,force "$RAW" "$M"
echo "=== 系统版本 ==="
grep -A1 ProductVersion "$M/System/Library/CoreServices/SystemVersion.plist" | head -3
echo "=== OpenGLES.framework ==="
ls -l "$M/System/Library/Frameworks/OpenGLES.framework/" 2>/dev/null | head -8
GL="$M/System/Library/Frameworks/OpenGLES.framework/OpenGLES"
if [ -f "$GL" ]; then
  cp "$GL" /root/fuxi/OpenGLES-20H392.bin
  echo "已取出: /root/fuxi/OpenGLES-20H392.bin ($(stat -c%s /root/fuxi/OpenGLES-20H392.bin) B)"
fi
sync
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true
echo VERIFY_ROOT_OK

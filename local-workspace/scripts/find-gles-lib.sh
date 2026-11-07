#!/bin/bash
set -uo pipefail
RAW=/root/fuxi/root8.raw
M=/root/fuxi/mnt/root8
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,ro,force "$RAW" "$M"

echo "=== OpenGLES 框架里有什么 ==="
ls -l "$M/System/Library/Frameworks/OpenGLES.framework/" 2>/dev/null
echo
echo "=== /usr/lib 下的 GLES 库 ==="
ls -l "$M/usr/lib/" 2>/dev/null | grep -i -E 'GLES|EGL|OpenGL' 
echo
echo "=== 其它可能的 GLES 位置 ==="
find "$M/System/Library" -maxdepth 4 -name '*GLES*' 2>/dev/null | head -10
echo
echo "=== 文件大小与类型 ==="
for f in "$M/System/Library/Frameworks/OpenGLES.framework/libGLESv2.dylib" \
         "$M/System/Library/Frameworks/OpenGLES.framework/OpenGLES"; do
  [ -f "$f" ] && ls -l "$f" && head -c 8 "$f" | xxd | head -1
done
sync
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

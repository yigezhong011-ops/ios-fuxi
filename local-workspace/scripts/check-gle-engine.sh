#!/bin/bash
set -uo pipefail
RAW=/root/fuxi/verify-root.raw
M=/root/fuxi/mnt/verify
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$RAW" "$M" 2>/dev/null || true
echo "=== GLEngine.bundle ==="
ls -l "$M/System/Library/Frameworks/OpenGLES.framework/GLEngine.bundle/" 2>/dev/null | head -10
echo
echo "=== 共享缓存是否存在 ==="
ls -lh "$M/System/Library/Caches/com.apple.dyld/" 2>/dev/null | head -6
echo
echo "=== 是否有 ipsw / dsc_extractor 可用 ==="
which ipsw dsc_extractor 2>/dev/null || echo "no extractor"
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

#!/bin/bash
set -uo pipefail
S=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
echo "=== loader 源码里与绘制/logo/进度相关的 ==="
grep -n -iE 'logo|progress|bar|draw|fb|framebuffer|pixel' "$S"/*.c "$S"/*.S 2>/dev/null | head -20
echo
echo "=== 源码文件清单 ==="
ls -l "$S" | head -15
echo
echo "=== 我们的内核里与 framebuffer 绘制相关的 ==="
grep -rn -iE 'draw|logo|progress' /root/ios-fuxi/xnu/fuxi-scanout/*.cpp /root/ios-fuxi/xnu/fuxi-scanout/*.c 2>/dev/null | head -10
ls /root/ios-fuxi/xnu | head -20

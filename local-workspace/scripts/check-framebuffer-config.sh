#!/bin/bash
set -uo pipefail
W=/root/fuxi/fork-device
echo "=== 设备仓库里与 framebuffer/display 相关的脚本 ==="
ls "$W/scripts" | grep -i 'display\|gop\|framebuffer\|scanout'
echo
echo "=== board.toml 的 archives 列表 ==="
sed -n '/"archives"/,/]/p' "$W/board.toml" | sed 's/^/  /'
echo
echo "=== defconfig 里的 display/fb 开关 ==="
grep -n -i 'fb\|framebuffer\|gop\|display' "$W/configs/fuxi_gpu_defconfig" 2>/dev/null | head -12
echo
echo "=== 源码里对 GopFramebuffer 的引用 ==="
grep -rn 'GopFramebuffer\|gop_framebuffer' "$W"/*.toml "$W"/scripts/*.py 2>/dev/null | head -6

#!/bin/bash
set -uo pipefail
echo "=== 0082 里 kick 所在文件路径 ==="
grep -n '^--- a/\|^+++ b/' /root/ios-fuxi/xnu/patches/0082-fuxi-ram-bringup.patch | head -8
echo
echo "=== kick 实现上下文（0082 原文）==="
grep -n -B12 -A14 'void fuxi_display_kick' /root/ios-fuxi/xnu/patches/0082-fuxi-ram-bringup.patch | head -45

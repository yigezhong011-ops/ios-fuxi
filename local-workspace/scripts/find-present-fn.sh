#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== present() 定义位置 ==="
grep -n '::present' "$F" | head -5
echo
L=$(grep -n 'AppleCLCD::present' "$F" | head -1 | cut -d: -f1)
echo "present 在 $L 行，附近内容："
[ -n "${L:-}" ] && sed -n "$((L-2)),$((L+80))p" "$F"

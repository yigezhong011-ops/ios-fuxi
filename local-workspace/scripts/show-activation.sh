#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/tools/sweet-root-tweaks.py
echo "=== 激活相关代码 ==="
grep -n -i 'activation\|ark' "$F" | head -15
echo
echo "=== 对应函数体 ==="
L=$(grep -n -i 'def .*activ\|no mobileactivationd' "$F" | head -1 | cut -d: -f1)
[ -n "${L:-}" ] && sed -n "$((L-10)),$((L+45))p" "$F"

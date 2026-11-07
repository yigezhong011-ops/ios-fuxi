#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c
echo "=== 文件规模 ==="
wc -l "$F"
echo
echo "=== chip id / reset / power 相关 ==="
grep -n -i 'chip id\|chipid\|reset\|power\|rail\|ldo\|vdd\|enable' "$F" | head -25
echo
echo "=== 读取 chip id 的代码段 ==="
L=$(grep -n 'chip id' "$F" | head -1 | cut -d: -f1)
[ -n "${L:-}" ] && sed -n "$((L-25)),$((L+15))p" "$F"

#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-adreno/fuxi_gpu_scanout.inc
echo "=== 文件规模 ==="
wc -l "$F"
echo
echo "=== publish 相关 ==="
grep -n 'publish' "$F" | head -10
echo
echo "=== 函数体 ==="
sed -n "$(grep -n 'publish' "$F" | head -1 | cut -d: -f1),+30p" "$F"

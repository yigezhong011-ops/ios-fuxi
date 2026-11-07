#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/docs/sweet.md
echo "=== 文件规模 ==="
wc -l "$D"
echo
echo "=== 目录/小标题 ==="
grep -n '^#' "$D" | head -40
echo
echo "=== SpringBoard / 首次启动 相关段落 ==="
grep -n -i -B3 -A12 'springboard' "$D" | head -60

#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c
echo "=== 'starting in 30 s' 的位置与上下文 ==="
L=$(grep -n 'starting in' "$F" | head -1 | cut -d: -f1)
echo "行号: $L"
[ -n "${L:-}" ] && sed -n "$((L-30)),$((L+10))p" "$F"

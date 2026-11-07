#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-scanout/SweetSurface.cpp
echo "=== sweet_surface_gpu_copy 的返回点 ==="
grep -n 'return [0-9-]' "$F" | head -20
echo
echo "=== 函数体 ==="
L=$(grep -n 'sweet_surface_gpu_copy' "$F" | head -1 | cut -d: -f1)
sed -n "$((L-5)),$((L+60))p" "$F"

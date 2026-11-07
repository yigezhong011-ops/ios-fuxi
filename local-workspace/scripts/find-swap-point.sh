#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== swap 计数与完成点 ==="
grep -n 'swaps\|fSwap\|fDirty' "$F" | head -15
echo
echo "=== 500-560 行 ==="
sed -n '500,560p' "$F"

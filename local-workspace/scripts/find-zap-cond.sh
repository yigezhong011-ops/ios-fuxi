#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c
echo "文件: $F"
ls -l "$F" 2>/dev/null || find /root/ios-fuxi/xnu -name 'fuxi_adreno.c' | head -3
echo "=== 条件附近 ==="
grep -n 'gpu_extra\[13\]' "$F" | head -5
L=$(grep -n 'gpu_extra\[13\]\[2\]' "$F" | head -1 | cut -d: -f1)
[ -n "${L:-}" ] && sed -n "$((L-4)),$((L+4))p" "$F"

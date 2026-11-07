#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== fuxi_gpu_ready 定义 ==="
grep -rn 'fuxi_gpu_ready' --include='*.c' --include='*.h' --include='*.cpp' xnu/ | head -8
echo
F=xnu/fuxi-adreno/fuxi_adreno.c
echo "=== fuxigpu_fail 的作用 ==="
grep -n -B3 -A12 'fuxigpu_fail' "$F" | head -40
echo
echo "=== fuxi_gpu_ready 实现 ==="
S=$(grep -n 'fuxi_gpu_ready(void)' "$F" | head -1 | cut -d: -f1)
[ -n "$S" ] && sed -n "${S},$((S+25))p" "$F"

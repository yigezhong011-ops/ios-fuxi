#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== g_gpu_freq 表与 LEVEL_MAX ==="
grep -rn 'g_gpu_freq\|G_GPU_LEVEL_MAX\|g_gpu_select' "$D"/*.h "$D"/*.c 2>/dev/null | head -12
echo
echo "=== 频率表内容 ==="
grep -rn -A6 'g_gpu_freq\[\]' "$D"/*.c 2>/dev/null | head -14
echo
echo "=== select 函数体（可能在别处）==="
grep -rn -A10 'g_gpu_select(unsigned' "$D"/*.c 2>/dev/null | head -18

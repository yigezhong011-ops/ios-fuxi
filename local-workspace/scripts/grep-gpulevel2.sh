#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c
echo "=== G_GPU_LEVEL_MAX 与 g_gpu_select ==="
grep -n 'G_GPU_LEVEL_MAX\|g_gpu_select\|struct g_gpu\|g_gpu_levels\|khz' "$F" | head -30
echo
echo "=== g_gpu_select 实现 ==="
awk '/g_gpu_select\(/{p=1} p{print NR": "$0} p&&/^}/{exit}' "$F" | head -40

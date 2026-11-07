#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c
echo "=== 相关行号 ==="
grep -n 'g_gpu_freq' "$F" | head
grep -n 'g_gpu_select' "$F" | head
grep -n 'G_GPU_LEVEL' "$F" | head
echo
echo "=== 定义 g_gpu_select / 表的区域（搜整个文件里的 static const）==="
grep -n 'static const\|static.*freq\|static.*level' "$F" | head -15
echo
echo "=== 520-545 行 ==="
sed -n '515,545p' "$F"

#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== 频率表 / 档位上限 的定义 ==="
grep -rn 'G_GPU_LEVEL_MAX\|g_gpu_freq\|gpu_freq\|LEVEL_MAX' "$D" 2>/dev/null | head -12
echo
echo "=== .inc 后端里的 CLOCK 部分 ==="
grep -n 'level\|freq\|khz\|OPP' "$D"/fuxi_gpu_abi_backend.inc 2>/dev/null | head -20
echo
echo "=== 哪个文件定义了 g_gpu_select ==="
grep -rln 'g_gpu_select' "$D" 2>/dev/null

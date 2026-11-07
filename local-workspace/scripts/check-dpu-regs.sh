#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c
echo "=== G4_FB_PA / 扫描输出常量 ==="
grep -n 'G4_FB_PA\|G4_FB_VA\|0xae0501\|0xae0500\|SCANOUT' "$F" | head -20
echo
echo "=== 扫描输出配置函数 ==="
grep -n -A18 'fuxi_gpu_scanout_configure' "$F" | head -40

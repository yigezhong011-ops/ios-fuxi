#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c
echo "=== 驱动用的总线和地址 ==="
grep -n 'FT_SE_PA\|FT_GPI_PA\|FT_SMMU_PA\|FT_GCC_PA\|FT_TLMM_PA\|FT_RESET\|FT_IRQ' "$F" | head -12
echo
echo "=== 驱动头注释里的硬件描述 ==="
sed -n '1,20p' "$F"

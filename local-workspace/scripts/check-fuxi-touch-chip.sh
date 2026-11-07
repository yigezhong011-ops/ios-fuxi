#!/bin/bash
set -uo pipefail
D=/root/fuxi/dtbcmp/final.dts
echo "=== 设备树里所有触控相关节点 ==="
grep -n -i 'goodix\|focaltech\|ft3\|fts@\|novatek\|nt36\|qcom,i2c-touch-active\|spi.*touch\|touch.*spi' "$D" 2>/dev/null | head -20 | cut -c1-150
echo
echo "=== 含 touch 的 compatible ==="
grep -o 'compatible = "[^"]*touch[^"]*"' "$D" 2>/dev/null | sort -u | head -10
echo
echo "=== SPI 上的设备（bus 号 + 片选）==="
grep -n -B2 -A2 'spi-max-frequency' "$D" 2>/dev/null | grep -i 'goodix\|focal\|novatek\|compatible' | head -10 | cut -c1-140

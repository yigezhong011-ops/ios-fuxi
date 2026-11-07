#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc
echo "=== 35-75 行 ==="
awk 'NR>=35 && NR<=75 {printf "%4d| %s\n", NR, $0}' "$D" | cut -c1-160
echo
echo "=== 其中的 PCD 赋值 ==="
grep -nE 'Pcd[A-Za-z]+\.' "$D" | head -20 | cut -c1-150

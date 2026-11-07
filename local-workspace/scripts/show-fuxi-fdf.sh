#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg
echo "=== fuxi.fdf 行数 ==="
wc -l "$P/fuxi.fdf"
echo
echo "=== 前 40 行 ==="
awk 'NR<=40 {printf "%3d| %s\n", NR, $0}' "$P/fuxi.fdf" | cut -c1-140
echo
echo "=== 有没有 include DXE.inc ==="
grep -n 'include\|DXE.inc\|APRIORI' "$P/fuxi.fdf" | head -10 | cut -c1-140

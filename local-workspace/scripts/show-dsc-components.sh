#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc
echo "=== [Components] 段在哪 ==="
grep -n '^\[Components\]' "$D"
echo
echo "=== 该段前 25 行 ==="
awk '/^\[Components\]/{found=NR} found && NR>=found && NR<found+25 {printf "%4d| %s\n", NR, $0}' "$D" | cut -c1-130
echo
echo "=== 有没有 include 组件列表 ==="
grep -n 'include.*inc\|!include' "$D" | head -10 | cut -c1-130

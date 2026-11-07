#!/bin/bash
set -uo pipefail
D=/root/build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc
echo "=== DXE.inc 1-90 行（含所有 !if / !endif 与 USB/充电行）==="
awk 'NR<=90 {printf "%4d| %s\n", NR, substr($0,1,120)}' "$D"

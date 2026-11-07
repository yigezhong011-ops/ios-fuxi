#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon51/boot.log
echo "=== FUXI MTL gate / 帧统计 ==="
tr -d '\000' < "$L" | grep -a 'FUXI MTL' | tail -12
echo
echo "=== 进度 / swap / 扫描 ==="
printf 'exec=%s SpringBoard=%s swaps=%s scanout=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'SWEET FB: swap')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1 | cut -d= -f2)"
echo
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -2

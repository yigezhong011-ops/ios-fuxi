#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon49/boot.log
echo "=== 进度 ==="
printf 'exec=%s SpringBoard=%s swaps=%s scanout=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'SWEET FB: swap')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1 | cut -d= -f2)"
echo
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -2
echo
echo "=== 帧统计 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats' | tail -2

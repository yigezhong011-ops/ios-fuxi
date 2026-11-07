#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon48/boot.log
echo "=== 进度 / SpringBoard ==="
printf 'exec=%s SpringBoard=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')"
echo
echo "=== swap / 扫描 ==="
tr -d '\000' < "$L" | grep -a -c 'SWEET FB: swap' || true
tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1
echo
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -2
echo
echo "=== 面板/背光 ==="
tr -d '\000' < "$L" | grep -a -i 'backlight\|display on' | tail -3

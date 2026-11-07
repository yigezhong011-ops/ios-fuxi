#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon52/boot.log
echo "=== FUXI MTL 关键行 ==="
tr -d '\000' < "$L" | grep -a 'FUXI MTL' | tail -16
echo
echo "=== 进度 ==="
printf 'exec=%s SpringBoard=%s swaps=%s scanout=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'SWEET FB: swap')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1 | cut -d= -f2)"

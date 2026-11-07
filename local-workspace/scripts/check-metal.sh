#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon46/boot.log
echo "=== 进度 ==="
printf 'exec=%s SpringBoard=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')"
echo
echo "=== FuxiMetal / metal2vulkan ==="
tr -d '\000' < "$L" | grep -a -i 'fuximetal\|metal2vulkan\|metal' | tail -8
echo
echo "=== 帧 / 扫描 ==="
tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats' | tail -2
echo
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -2

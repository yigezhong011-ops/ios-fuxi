#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon31/boot.log
echo "=== 这次（mon31）总体 ==="
printf 'exec=%s springboard=%s swaps=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -1)"
echo
echo "=== SpringBoard 相关输出 ==="
tr -d '\000' < "$L" | grep -a -i 'springboard' | tail -6
echo
echo "=== 最后的服务 ==="
tr -d '\000' < "$L" | grep -a '^exec ' | sed 's/^exec //' | awk '!seen[$0]++' | tail -12
echo
echo "=== 最后 8 行（去噪）==="
tr -d '\000' < "$L" | grep -av 'SWEET ' | tail -8

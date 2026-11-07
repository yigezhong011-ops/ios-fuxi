#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon34/boot.log
echo "=== 汇总 ==="
printf 'exec=%s  SpringBoard=%s  swaps=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -1 | awk '{print $3}')"
echo
echo "=== 崩溃统计（bluetoothd/fairplayd 应消失）==="
tr -d '\000' < "$L" | grep -a -o 'CRASH [A-Za-z0-9._-]*' | sort | uniq -c | sort -rn | head -6
echo
echo "=== 最后 12 个不同服务 ==="
tr -d '\000' < "$L" | grep -a '^exec ' | sed 's/^exec //' | awk '!seen[$0]++' | tail -12
echo
echo "=== 最后 8 行（去噪）==="
tr -d '\000' < "$L" | grep -av 'SWEET ' | tail -8

#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon32/boot.log
echo "=== 汇总 ==="
printf 'exec=%s   SpringBoard=%s   swaps=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -1 | awk '{print $3}')"
echo
echo "=== 最后 12 个不同服务 ==="
tr -d '\000' < "$L" | grep -a '^exec ' | sed 's/^exec //' | awk '!seen[$0]++' | tail -12
echo
echo "=== 最近的错误/崩溃（最后 8 条）==="
tr -d '\000' < "$L" | grep -a 'CRASH\|panic\|Assertion' | tail -8
echo
echo "=== 最后 10 行（全部，去 DBG 噪声）==="
tr -d '\000' < "$L" | grep -av 'SWEET DBG' | tail -10

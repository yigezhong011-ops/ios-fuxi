#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon36/boot.log
echo "=== 崩溃统计（看 bluetoothd/fairplayd 是否已消失）==="
tr -d '\000' < "$L" | grep -a -o 'CRASH [A-Za-z0-9._-]*' | sort | uniq -c | sort -rn | head -8
echo
echo "=== SpringBoard ==="
tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard' || true
echo
echo "=== exec 总数 / swaps ==="
printf 'exec=%s swaps=%s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
  "$(tr -d '\000' < "$L" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -1 | awk '{print $3}')"
echo
echo "=== 最后 10 行 ==="
tr -d '\000' < "$L" | grep -av 'SWEET ' | tail -10

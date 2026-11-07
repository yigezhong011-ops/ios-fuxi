#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon25/boot.log
echo "=== FUXI KICK 诊断（前 8 次）==="
tr -d '\000' < "$L" | grep -a 'FUXI KICK' | head -10
echo
echo "=== 显示相关 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: display\|SWEET FB: AppleCLCD' | head -4
echo
echo "=== 帧统计 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats' | tail -2
echo
echo "=== 崩溃 ==="
tr -d '\000' < "$L" | grep -a -c 'CRASH SpringBoard' || true
tr -d '\000' < "$L" | grep -a -o 'CRASH [A-Za-z0-9._-]*' | sort | uniq -c | sort -rn | head -5

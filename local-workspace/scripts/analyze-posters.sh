#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon53/boot.log
echo "=== Poster 崩溃次数（按进程）==="
tr -d '\000' < "$L" | grep -a 'CRASH.*Poster' | sed 's/.*CRASH \([A-Za-z]*\).*/\1/' | sort | uniq -c
echo
echo "=== 第一次/最后一次 ==="
tr -d '\000' < "$L" | grep -a 'CRASH.*Poster' | head -2
tr -d '\000' < "$L" | grep -a 'CRASH.*Poster' | tail -2
echo
echo "=== 是否有 SpringBoard 画面相关（swap 时间线）==="
tr -d '\000' < "$L" | grep -a -n 'SWEET FB: swap' | head -3
tr -d '\000' < "$L" | grep -a -n 'SWEET FB: swap' | tail -3

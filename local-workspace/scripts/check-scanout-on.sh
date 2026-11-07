#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon26/boot.log
echo "=== SCANOUT 是否启用 ==="
tr -d '\000' < "$L" | grep -a 'FUXI SCANOUT' | head -6
echo
echo "=== FUXI KICK（新补丁的诊断）==="
tr -d '\000' < "$L" | grep -a 'FUXI KICK' | head -8
echo
echo "=== 帧统计 / 显示 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats\|SWEET FB: display' | tail -4
echo
echo "=== SpringBoard 崩溃 ==="
tr -d '\000' < "$L" | grep -a -c 'CRASH SpringBoard' || true

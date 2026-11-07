#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon42/boot.log
echo "=== 刷新上限 / 核心推荐 ==="
tr -d '\000' < "$L" | grep -a 'present up to\|recommended cores\|FUXI PERF: recommended' | head -5
echo
echo "=== 帧统计 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats' | tail -3
echo
echo "=== 帧提交数（swap）==="
tr -d '\000' < "$L" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -2
echo
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -4
echo
echo "=== perf 域状态 ==="
tr -d '\000' < "$L" | grep -a 'FUXI PERF:' | head -6

#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon43/boot.log
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -6
echo
echo "=== 帧统计 / 刷新 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats\|present up to' | tail -4
echo
echo "=== 核心推荐 ==="
tr -d '\000' < "$L" | grep -a 'recommended cores' | tail -3
echo
echo "=== CPU 频率 / perf ==="
tr -d '\000' < "$L" | grep -a 'FUXI PERF' | tail -6

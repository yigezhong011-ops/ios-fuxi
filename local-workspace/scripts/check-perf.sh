#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon41/boot.log
echo "=== 帧统计（新内核，无每帧日志）==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats\|SWEET FB: [0-9]* swaps\|FUXI SCANOUT: frame=' | tail -8
echo
echo "=== 触摸芯片 ID ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -6
echo
echo "=== CPU 数量 ==="
tr -d '\000' < "$L" | grep -a 'cpu [0-9] online\|SWEET CPU: cpu' | tail -8

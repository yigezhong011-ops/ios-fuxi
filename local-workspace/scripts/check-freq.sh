#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon41/boot.log
echo "=== 频率 / EPSS 相关 ==="
tr -d '\000' < "$L" | grep -a -i 'cpufreq\|FUXI PERF\|freq\|EPSS\|kHz\|MHz' | tail -15
echo
echo "=== 热状态 ==="
tr -d '\000' < "$L" | grep -a 'FUXI PERF: stats' | tail -3
echo
echo "=== 定时器/vsync ==="
tr -d '\000' < "$L" | grep -a -i 'vsync\|sweetfb_hz\|tick' | tail -8

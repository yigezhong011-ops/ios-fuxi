#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon46/boot.log
echo "=== SCANOUT 状态 ==="
tr -d '\000' < "$L" | grep -a 'FUXI SCANOUT' | head -8
echo "..."
tr -d '\000' < "$L" | grep -a 'FUXI SCANOUT' | tail -4
echo
echo "=== 呈现相关（present/how many swaps）==="
tr -d '\000' < "$L" | grep -a -i 'present\|swap\|dirty' | tail -8
echo
echo "=== 显示开关 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: display' | head -3

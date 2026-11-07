#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon27/boot.log
echo "=== 帧统计（CPU 拷贝是否生效）==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: stats' | tail -3
echo
echo "=== SCANOUT 帧 ==="
tr -d '\000' < "$L" | grep -a 'FUXI SCANOUT: frame=' | tail -3
echo
echo "=== SpringBoard 状态 ==="
tr -d '\000' < "$L" | grep -a 'exec SpringBoard\|CRASH SpringBoard' | tail -4
echo "崩溃数: $(tr -d '\000' < "$L" | grep -a -c 'CRASH SpringBoard' || true)"
echo
echo "=== 最后 12 行（非重复）==="
tr -d '\000' < "$L" | grep -av 'SWEET DBG' | grep -av 'matching1' | tail -12

#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon45/boot.log
echo "=== exec 数 ==="
tr -d '\000' < "$L" | grep -a -c '^exec ' || true
echo "=== SpringBoard ==="
tr -d '\000' < "$L" | grep -a 'exec SpringBoard' | tail -1
echo "=== 扫描帧 ==="
tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1
echo "=== 触摸 ==="
tr -d '\000' < "$L" | grep -a 'FUXI TOUCH' | tail -3
echo "=== 最后 6 行 ==="
tr -d '\000' < "$L" | tail -6

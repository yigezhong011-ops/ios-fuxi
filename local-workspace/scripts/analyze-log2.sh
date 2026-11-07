#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon/boot.log
echo "=== SpringBoard 全部相关行 ==="
grep -n 'SpringBoard' "$L" | head -40
echo
echo "=== 500-620 行（SpringBoard/backboardd 启动时刻）==="
sed -n '500,620p' "$L"
echo
echo "=== 最后 60 行（当前卡住的位置）==="
tail -n 60 "$L"

#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon13/boot.log
echo "=== swap 数量 ==="
grep -a -c 'SWEET FB: swap' "$L" || true
echo "=== 最后 5 条 swap ==="
grep -a -n 'SWEET FB: swap' "$L" | tail -5
echo "=== display on/off ==="
grep -a -n 'SWEET FB: display' "$L" | head -10
echo "=== stats（600 帧统计）==="
grep -a -n 'SWEET FB: stats' "$L" | tail -5 || echo "(no stats)"
echo "=== diff 统计 ==="
grep -a -n 'FUXI UNIXNU FB' "$L" | tail -5
echo "=== 行数 ==="; wc -l "$L"
echo "=== 末尾 ==="
tail -c 900 "$L" | tr -d '\000' | tail -6

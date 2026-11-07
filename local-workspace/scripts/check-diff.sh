#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon8/boot.log
echo "=== 行数 ==="; wc -l "$L"
echo "=== SWEET DBG ==="
grep -a -c 'SWEET DBG' "$L" || true
grep -a -n 'SWEET DBG' "$L" | head -10 || true
echo "=== swap ==="
grep -a -n 'SWEET FB: swap' "$L" | head -5 || true
echo "=== diff ==="
grep -a -n 'FUXI UNIXNU FB' "$L" | head -5 || true
echo "=== 关键节点 ==="
grep -a -n 'root file in userdata\|exec launchd\|exec SpringBoard' "$L" | head -6 || true
echo "=== 末尾 ==="
tail -c 1200 "$L" | tr -d '\000' | tail -10

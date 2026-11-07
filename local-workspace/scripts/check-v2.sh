#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon9/boot.log
echo "=== SWEET DBG: panel ==="
grep -a -n 'SWEET DBG: panel' "$L" | head -5 || echo "(none)"
echo "=== 其它 SWEET DBG ==="
grep -a -n 'SWEET DBG' "$L" | head -8 || echo "(none)"
echo "=== diff 统计 ==="
grep -a -n 'FUXI UNIXNU FB' "$L" | head -5 || echo "(none)"
echo "=== 行数 / 末尾 ==="
wc -l "$L"
tail -c 600 "$L" | tr -d '\000'

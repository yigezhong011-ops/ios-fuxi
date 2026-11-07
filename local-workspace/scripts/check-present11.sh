#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon11/boot.log
echo "=== swap / DBG ==="
grep -a -n 'SWEET FB: swap' "$L" | head -8 || echo "(no swap)"
grep -a -n 'SWEET DBG' "$L" | head -8 || echo "(no dbg)"
grep -a -n 'FUXI UNIXNU FB' "$L" | head -5 || echo "(no diff lines)"
echo
echo "=== SpringBoard 之后的关键节点 ==="
grep -a -n 'exec SpringBoard\|exec backboardd\|exec posterboard\|display on' "$L" | head -8
echo
echo "=== 最后 40 行里非 ReportCrash 的 ==="
tail -c 6000 "$L" | tr -d '\000' | grep -av 'ReportCrash' | tail -20

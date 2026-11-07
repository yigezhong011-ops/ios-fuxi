#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon22/boot.log
echo "=== GPU 相关 ==="
grep -a 'FUXI GPU' "$L" | tail -12
echo
echo "=== IOAccelerator / backboardd ==="
grep -a -c 'IOAcceleratorES' "$L" || true
grep -a 'IOK backboardd: matching' "$L" | tail -2
echo
echo "=== swap / display ==="
grep -a -c 'SWEET FB: swap' "$L" || true
grep -a 'SWEET FB: display' "$L" | head -4
grep -a 'SWEET DBG: panel\|SWEET DBG: ctl0' "$L" | head -3
echo
echo "=== 行数 ==="; wc -l "$L"

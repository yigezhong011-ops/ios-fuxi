#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon14/boot.log
echo "=== 行数 ==="; wc -l "$L"
echo "=== swap 数 ==="
grep -a -c 'SWEET FB: swap' "$L" || true
grep -a -n 'SWEET FB: swap' "$L" | tail -3
echo "=== idlefb 模式行 ==="
grep -a -n 'demand timer\|idle' "$L" | head -5 || echo "(none)"
echo "=== display on/off ==="
grep -a -n 'SWEET FB: display' "$L" | head -6
echo "=== 1000 swaps ==="
grep -a -n 'swaps$' "$L" | head -5 || echo "(none)"
echo "=== DBG ==="
grep -a -n 'SWEET DBG: ctl0' "$L" | head -3

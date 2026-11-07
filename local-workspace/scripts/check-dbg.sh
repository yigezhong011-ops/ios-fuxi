#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon7/boot.log
echo "=== SWEET DBG 行 ==="
grep -a -n 'SWEET DBG' "$L" | head -30 || echo "(none)"
echo
echo "=== swap 行 ==="
grep -a -n 'SWEET FB: swap' "$L" | head -10 || echo "(none)"
echo
echo "=== 行数 ==="; wc -l "$L"

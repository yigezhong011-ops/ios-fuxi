#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon6/boot.log
echo "=== swap 前后 60 行（1690-1760）==="
sed -n '1690,1760p' "$L" | tr -d '\000'
echo
echo "=== 全部 swap 行 ==="
grep -a -n 'SWEET FB: swap' "$L" | tr -d '\000'
echo
echo "=== 全部 SWEET FB 非 sel 行 ==="
grep -a -n 'SWEET FB' "$L" | grep -av ' sel ' | tr -d '\000'

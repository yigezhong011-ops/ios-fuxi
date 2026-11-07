#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 尾部 30 行（去乱码）==="
tail -60 "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -22 | cut -c1-170
echo
echo "=== 所有 *** 行 ==="
grep -a '\*\*\*' "$L" | tail -5 | cut -c1-170

#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 行数 $(wc -l < "$L" | tr -d ' ') ==="
echo "=== Error 1 定位 ==="
line=$(grep -an 'Error 1' "$L" 2>/dev/null | head -1 | cut -d: -f1)
echo "行: ${line:-无}"
if [ -n "${line:-}" ]; then
  sed -n "$((line>30?line-30:1)),$((line+1))p" "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -20 | cut -c1-175
fi

#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 行数 ==="
wc -l "$L" 2>/dev/null
echo
echo "=== Undefined symbols 段 ==="
grep -n 'Undefined symbols' "$L" 2>/dev/null | head -2
line=$(grep -n 'Undefined symbols' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "${line:-}" ]; then
  sed -n "$line,$((line+24))p" "$L" | cut -c1-140
fi
echo
echo "=== 是否有 error: 行 ==="
grep -a 'error:' "$L" 2>/dev/null | head -4 | cut -c1-170

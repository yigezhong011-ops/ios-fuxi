#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== Error 1 行（真正的失败命令）==="
grep -an 'Error 1' "$L" 2>/dev/null | head -6 | cut -c1-170
echo
line=$(grep -an 'Error 1' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "${line:-}" ]; then
  echo "=== 该行前 25 行 ==="
  sed -n "$((line>25?line-25:1)),$((line+2))p" "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -18 | cut -c1-175
fi

#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 链接错误上下文 ==="
line=$(grep -an 'linker command failed' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "${line:-}" ]; then
  sed -n "$((line>25?line-25:1)),$((line+1))p" "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -18 | cut -c1-175
else
  grep -an 'error\|Error' "$L" | head -6 | tr -d '\000' | sed 's/[^[:print:]]//g' | cut -c1-175
fi

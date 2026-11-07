#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 第一条 *** 失败 ==="
line=$(grep -n '\*\*\*' "$L" | head -1 | cut -d: -f1)
echo "行 $line"
if [ -n "${line:-}" ]; then
  sed -n "$((line>40?line-40:1)),$((line+3))p" "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -25 | cut -c1-170
fi

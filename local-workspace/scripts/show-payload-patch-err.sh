#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== payload 步骤的错误上下文 ==="
n=$(grep -an 'payload-patch' "$L" | head -1 | cut -d: -f1)
echo "行 $n"
if [ -n "${n:-}" ]; then
  awk -v s=$((n>40?n-40:1)) -v e=$n 'NR>=s && NR<=e' "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE' | grep -v '^$' | tail -25 | cut -c1-175
fi

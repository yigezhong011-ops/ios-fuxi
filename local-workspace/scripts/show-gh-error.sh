#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== ##[error] 行 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -an '##\[error\]' | head -6 | cut -c1-190
echo
echo "=== 该行前后 ==="
n=$(tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -an '##\[error\]' | head -1 | cut -d: -f1)
if [ -n "${n:-}" ]; then
  awk -v s=$((n>12?n-12:1)) -v e=$n 'NR>=s && NR<=e' "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE' | tail -12 | cut -c1-175
fi

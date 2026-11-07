#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== payload 步骤相关的错误 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'payload' | grep -av 'CCC_OVERRIDE' | tail -14 | cut -c1-180
echo
echo "=== Build payload 那一步的输出 ==="
n=$(grep -an 'name: Build payload\|== payload\|payload: ' "$L" | head -1 | cut -d: -f1)
echo "行 ${n:-无}"
if [ -n "${n:-}" ]; then
  awk -v s="$n" 'NR>=s && NR<=s+30' "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE' | grep -v '^$' | tail -20 | cut -c1-180
fi

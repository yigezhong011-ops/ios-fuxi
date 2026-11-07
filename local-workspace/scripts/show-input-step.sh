#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
n=$(grep -an 'Check the inputs' "$L" | head -1 | cut -d: -f1)
echo "Check the inputs 从行 $n 开始"
awk -v s="$n" 'NR>=s && NR<=s+60' "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -av '^$' | tail -30 | cut -c1-175

#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 600-640 行 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | awk 'NR>=598 && NR<=640' | grep -av 'CCC_OVERRIDE' | grep -v '^$' | tail -20 | cut -c1-175

#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== Check the inputs 段 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a -A3 -B3 'error\|missing\|requires\|payload' | grep -av 'CCC_OVERRIDE' | head -30 | cut -c1-175

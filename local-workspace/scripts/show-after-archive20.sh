#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 767 行之后的全部内容 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | awk 'NR>767' | grep -av 'CCC_OVERRIDE\|Adding argument' | grep -v '^$' | head -30 | cut -c1-175

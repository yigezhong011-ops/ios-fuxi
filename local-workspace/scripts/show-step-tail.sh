#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 尾部 40 行（去噪）==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE\|Adding argument\|Entering .\|git config\|file:/' | grep -v '^$' | tail -30 | cut -c1-175

#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 所有 ::error:: 与 fail() 触发点 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a '::error::\|^.*fail "\|Process completed with exit' | head -10 | cut -c1-190
echo
echo "=== 最后 30 行非噪声 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE\|git config\|Entering\|file:' | grep -v '^$' | tail -20 | cut -c1-175

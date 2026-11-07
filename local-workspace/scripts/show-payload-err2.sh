#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== unixnu: 消息 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'unixnu:' | grep -av CCC_OVERRIDE | tail -6 | cut -c1-190
echo
echo "=== trust cache / sha / bundle 相关 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -ai 'trust' | grep -av CCC_OVERRIDE | tail -10 | cut -c1-190

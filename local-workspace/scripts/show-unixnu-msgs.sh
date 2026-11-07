#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 所有 unixnu: 消息 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'unixnu:' | grep -av 'CCC_OVERRIDE' | tail -8 | cut -c1-180
echo
echo "=== 最后的 archive 行 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'kernel: archive' | tail -3 | cut -c1-150

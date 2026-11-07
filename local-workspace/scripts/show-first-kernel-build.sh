#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 第一次 build kernel 的输出 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -an 'unixnu build kernel\|== kernel:\|kernel-bootstrap\|error\|failed' | grep -av 'CCC_OVERRIDE' | sed -n '1,24p' | cut -c1-175

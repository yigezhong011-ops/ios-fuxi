#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== ld: / Undefined / 未定义 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE\|Adding argument' | grep -a 'ld: \|Undefined symbols\|referenced from' | tail -12 | cut -c1-175
echo
echo "=== 最后一条 '*' 失败 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a '^\*\*\*\|make\[.*\*\*\*' | tail -3 | cut -c1-175

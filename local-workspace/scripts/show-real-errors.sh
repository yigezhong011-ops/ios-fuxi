#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 全部非 CCC 噪声的错误行 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE_OPTIONS\|Adding argument\|Wno-' | grep -a 'error\|Error\|cannot find\|No such' | head -12 | cut -c1-175
echo
echo "=== 尾部 12 行 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -av 'CCC_OVERRIDE_OPTIONS\|Adding argument' | grep -v '^$' | tail -12 | cut -c1-175

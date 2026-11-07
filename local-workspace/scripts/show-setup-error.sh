#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== SETUP 阶段的 error ==="
grep -an 'Error 1\|error:' "$L" 2>/dev/null | head -6 | tr -d '\000' | sed 's/[^[:print:]]//g' | cut -c1-175
echo
echo "=== 尾部 15 行 ==="
tail -300 "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -15 | cut -c1-175

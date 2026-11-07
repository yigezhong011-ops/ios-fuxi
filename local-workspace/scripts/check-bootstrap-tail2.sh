#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 行数 ==="; wc -l "$L" | tr -d '\n'; echo
echo "=== 尾部 20 行（去控制符）==="
tail -400 "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -20 | cut -c1-170
echo
echo "=== 链接相关 ==="
grep -a 'ld: \|Undefined\|LINK\|mach.development' "$L" 2>/dev/null | tail -6 | cut -c1-170

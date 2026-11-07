#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 行数 ==="; wc -l "$L" | tr -d '\n'; echo
echo "=== 最后 60 行（去控制符）==="
tail -200 "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -40 | cut -c1-175

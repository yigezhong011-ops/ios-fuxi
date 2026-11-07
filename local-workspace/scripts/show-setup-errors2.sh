#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 前 400 行里的真实错误 ==="
head -400 "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -a 'error\|Error\|not found\|No such' | head -12 | cut -c1-175

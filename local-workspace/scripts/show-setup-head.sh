#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 日志前 50 行（SETUP 失败处）==="
head -50 "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -30 | cut -c1-175

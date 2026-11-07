#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 含 error 的行（最后 20 条，去乱码）==="
grep -ai 'error' "$L" 2>/dev/null | tr -d '\000' | sed 's/[^[:print:]]//g' | tail -20 | cut -c1-180

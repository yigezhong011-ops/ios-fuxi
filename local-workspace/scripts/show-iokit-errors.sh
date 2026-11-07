#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 5300-5480 里的 error 行 ==="
sed -n '5300,5480p' "$L" | grep -a 'error:' | cut -c1-190
echo
echo "=== 这些 error 的前后几行 ==="
sed -n '5300,5480p' "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -a -B2 -A6 'error:' | head -30 | cut -c1-175

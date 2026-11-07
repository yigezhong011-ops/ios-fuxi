#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 提到 IOUserServer 且含 error 的行 ==="
grep -a 'IOUserServer' "$L" 2>/dev/null | grep -a 'error' | head -6 | tr -d '\000' | sed 's/[^[:print:]]//g' | cut -c1-190
echo
echo "=== 全日志里 ' error:' 的最后 6 条 ==="
grep -an ' error:' "$L" 2>/dev/null | tail -6 | tr -d '\000' | sed 's/[^[:print:]]//g' | cut -c1-190

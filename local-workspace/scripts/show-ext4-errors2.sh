#!/bin/bash
set -uo pipefail
L=/root/kernel-ext4.log
echo "=== 日志大小 ==="
wc -l "$L" 2>/dev/null
echo
echo "=== 搜 Error / error / Stop ==="
grep -nE 'Error [0-9]|error|Stop\.' "$L" 2>/dev/null | head -15
echo
echo "=== 最后 40 行（去乱码）==="
tail -40 "$L" 2>/dev/null | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -20

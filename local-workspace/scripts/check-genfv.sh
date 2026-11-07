#!/bin/bash
set -uo pipefail
L=/root/unixnu-fw4.log
echo "=== ERROR 2000 上下文 ==="
grep -n -A8 'ERROR 2000' "$L" | head -20
echo
echo "=== 全部 GenFv 相关 ==="
grep -n -i 'GenFv\|same file GUID\|duplicate' "$L" | tail -10

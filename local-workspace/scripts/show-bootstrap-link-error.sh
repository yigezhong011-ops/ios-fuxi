#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 行数 ==="
wc -l "$L" 2>/dev/null
echo
echo "=== 链接错误 ==="
grep -n 'Undefined symbols\|ld: \|symbol(s) not found\|referenced from' "$L" 2>/dev/null | head -14 | cut -c1-170
echo
echo "=== 未定义符号名 ==="
grep -o '"_[_a-zA-Z][_a-zA-Z0-9]*", referenced' "$L" 2>/dev/null | sort -u | head -16
echo
echo "=== 尾部 ==="
tail -6 "$L" | cut -c1-170

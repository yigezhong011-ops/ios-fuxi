#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== 未定义符号（引号内的 _native_* / _sheng_*）==="
sed -n '520,600p' "$L" | grep -o '"[_a-z][_a-z0-9]*"' | sort -u | head -20
echo
echo "=== 链接错误附近 ==="
sed -n '575,600p' "$L" | cut -c1-170

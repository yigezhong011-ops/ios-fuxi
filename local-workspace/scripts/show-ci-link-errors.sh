#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== 链接错误 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'Undefined symbols\|ld: symbol\|referenced from\|No XNU symbol' | tail -10 | cut -c1-175
echo
echo "=== bootstrap 段落末尾 ==="
line=$(grep -an 'archive-01-build-corecrypto-14' "$L" | head -1 | cut -d: -f1)
if [ -n "${line:-}" ]; then
  sed -n "$((line>30?line-30:1)),$((line))p" "$L" | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -18 | cut -c1-175
fi

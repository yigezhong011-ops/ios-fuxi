#!/bin/bash
set -uo pipefail
S=/root/ux2/fuxi/tree/scripts/build-xnu-4k-baseline.sh
echo "=== build_all_bootstrap 的调用处 ==="
grep -n 'build_all_bootstrap\|_bootstrap\|XNU_BUILD_TARGET' "$S" | head -10 | cut -c1-175
echo
echo "=== 该处上下文 ==="
n=$(grep -n 'build_all_bootstrap' "$S" | head -1 | cut -d: -f1)
[ -n "${n:-}" ] && awk -v s=$((n>18?n-18:1)) -v e=$((n+3)) 'NR>=s && NR<=e {printf "%4d| %s\n", NR, $0}' "$S" | cut -c1-175

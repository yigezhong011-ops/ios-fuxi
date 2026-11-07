#!/bin/bash
set -uo pipefail
S=/root/ux2/fuxi/tree/scripts/build-xnu-4k-baseline.sh
echo "=== XNU_EXTRA_LD_ARCHIVES 出现的位置 ==="
grep -n 'EXTRA_LD_ARCHIVES' "$S" | cut -c1-180
echo
echo "=== 上下文 ==="
n=$(grep -n 'EXTRA_LD_ARCHIVES' "$S" | head -1 | cut -d: -f1)
[ -n "${n:-}" ] && awk -v s=$((n>12?n-12:1)) -v e=$((n+8)) 'NR>=s && NR<=e {printf "%4d| %s\n", NR, $0}' "$S" | cut -c1-170

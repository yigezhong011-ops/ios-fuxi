#!/bin/bash
set -uo pipefail
S=/root/ux2/fuxi/tree/scripts/build-xnu-4k-baseline.sh
echo "=== BOOTSTRAP 相关逻辑 ==="
grep -n 'BOOTSTRAP\|bootstrap' "$S" | head -14 | cut -c1-175
echo
echo "=== 770-790 行 ==="
awk 'NR>=768 && NR<=790 {printf "%4d| %s\n", NR, $0}' "$S" | cut -c1-175

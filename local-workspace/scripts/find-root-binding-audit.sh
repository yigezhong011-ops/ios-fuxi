#!/bin/bash
set -uo pipefail
S=/root/fuxi/fork-device/scripts/build-xnu-4k-baseline.sh
n=$(grep -n 'root-binding audit requires' "$S" | head -1 | cut -d: -f1)
echo "行 $n"
awk -v s=$((n>14?n-14:1)) -v e=$((n+4)) 'NR>=s && NR<=e {printf "%4d| %s\n", NR, $0}' "$S" | cut -c1-175

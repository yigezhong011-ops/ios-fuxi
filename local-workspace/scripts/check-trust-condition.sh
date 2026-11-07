#!/bin/bash
set -uo pipefail
S=/root/fuxi/fork-device/scripts/build-xnu-4k-baseline.sh
echo "=== 那句 build 检查的条件 ==="
n=$(grep -n 'actual mounted-media binding' "$S" | head -1 | cut -d: -f1)
echo "行 $n"
awk -v s=$((n>12?n-12:1)) -v e=$((n+2)) 'NR>=s && NR<=e {printf "%4d| %s\n", NR, $0}' "$S" | cut -c1-175

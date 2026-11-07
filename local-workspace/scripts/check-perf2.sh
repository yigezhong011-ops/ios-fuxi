#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon41/boot.log
echo "=== 各域启用结果 ==="
tr -d '\000' < "$L" | grep -a 'FUXI PERF:' | head -12
echo
echo "=== fuxicores 的用途 ==="
grep -n -B5 -A12 'fuxicores' /root/ios-fuxi/xnu/fuxi-perf/fuxi_perf.c | head -30

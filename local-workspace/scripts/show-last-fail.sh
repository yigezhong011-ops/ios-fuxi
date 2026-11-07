#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== 失败前最后一个 archive 与错误 ==="
grep -n 'kernel: archive' "$L" | tail -4 | cut -c1-140
echo
sed -n '735,760p' "$L" | cut -c1-170
echo
echo "=== 有没有 No reference candidate ==="
grep -c 'No reference candidate' "$L" 2>/dev/null || echo 0
echo "=== prelink / 候选 ==="
grep -n 'kernel: prelink\|native-prelink\|stub archive' "$L" | head -6 | cut -c1-150

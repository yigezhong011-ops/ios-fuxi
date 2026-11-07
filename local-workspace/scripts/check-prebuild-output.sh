#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== pre_build 阶段的输出（搜 native-prelink / payload / kernel）==="
grep -n 'native-prelink' "$L" | head -8 | cut -c1-200
echo
grep -n 'kernel/kernel.macho' "$L" | head -6 | cut -c1-200
echo
echo "=== pre_build 步骤区间（第 380-540 行里的关键行）==="
sed -n '380,540p' "$L" | grep -E 'defconfig|build kernel|prelink|mkdir|cp |ls -l|total|error' | head -20 | cut -c1-200

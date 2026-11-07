#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== pre_build 阶段（stub / prelink / 候选）==="
grep -n 'stub archive\|fuxi-link-stubs\|mach.development\|native-prelink\|kernel.macho\|No reference candidate' "$L" | head -16 | cut -c1-170
echo
echo "=== 主构建失败点 700-745 ==="
sed -n '700,745p' "$L" | cut -c1-170

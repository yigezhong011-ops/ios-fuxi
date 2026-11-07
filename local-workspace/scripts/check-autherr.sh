#!/bin/bash
set -uo pipefail
F=/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c
echo "=== autherr 的赋值 ==="
grep -n 'autherr' "$F" | head -10 | cut -c1-175
echo
echo "=== 155-190 行（fuxi 相关的 root 选择逻辑）==="
grep -n 'fuxi-owner-skip-root-auth\|owner_skip\|skip_root' "$F" | head -6 | cut -c1-175
echo
echo "=== 1030-1080 行 ==="
awk 'NR>=1030 && NR<=1080 {printf "%4d| %s\n", NR, $0}' "$F" | cut -c1-170

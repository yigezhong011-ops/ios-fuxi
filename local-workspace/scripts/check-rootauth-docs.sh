#!/bin/bash
set -uo pipefail
F=/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c
echo "=== 1057-1075（require_rootauth 决定处）==="
awk 'NR>=1057 && NR<=1075 {printf "%4d| %s\n", NR, $0}' "$F" | cut -c1-175
echo
echo "=== 文档里关于 rootauth / 根鉴权 ==="
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
grep -rn 'rootauth\|ROOTAUTH\|root authentication\|fk-owner\|跳过根\|根卷鉴权' "$D" --include='*.md' | head -12 | cut -c1-175

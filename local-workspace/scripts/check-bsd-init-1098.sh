#!/bin/bash
set -uo pipefail
F=/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c
echo "=== 1080-1110 行 ==="
awk 'NR>=1080 && NR<=1110 {printf "%4d| %s\n", NR, $0}' "$F" | cut -c1-175
echo
echo "=== 相关的 boot arg 名字 ==="
grep -n 'skip_root_auth\|owner_skip\|not authenticated' "$F" | head -8 | cut -c1-175

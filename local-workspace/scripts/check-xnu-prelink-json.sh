#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== 树脚本里对 xnu-prelink 的引用 ==="
grep -rn 'xnu-prelink' "$T/scripts" "$T/kits" 2>/dev/null | head -10 | cut -c1-180
echo
echo "=== audit-mobile-graphics-legacy 怎么找候选 ==="
grep -n 'prelink\|candidate\|json' "$T/scripts/audit-mobile-graphics-legacy.py" 2>/dev/null | head -12 | cut -c1-170

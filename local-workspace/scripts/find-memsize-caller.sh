#!/bin/bash
set -uo pipefail
X=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/.cache/xnu-work
echo "=== 谁调用 hw.memsize / hw.logicalcpu ==="
grep -rn 'hw.memsize\|hw.logicalcpu\|hw.physicalcpu' "$X" --include='*.cmd' --include='Makefile*' --include='*.mk' --include='*.sh' 2>/dev/null | head -10
echo
echo "=== 这些行上下文 ==="
f=$(grep -rl 'hw.memsize' "$X" --include='*.cmd' 2>/dev/null | head -1)
echo "文件: $f"
[ -n "$f" ] && grep -n -B3 -A6 'hw.memsize' "$f" | head -30

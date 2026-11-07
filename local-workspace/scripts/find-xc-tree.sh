#!/bin/bash
set -uo pipefail
echo "=== 在整棵树里找 -xc ==="
grep -rn -- "'-xc'" /root/ux2/fuxi/tree --include='*.py' 2>/dev/null | head -8 | cut -c1-160
echo
echo "=== archive-11 日志尾部（真实报错）==="
L=/root/ux2/fuxi/logs/archive-11-build-boot-progress.log
wc -l "$L" 2>/dev/null
tail -25 "$L" 2>/dev/null | cut -c1-170

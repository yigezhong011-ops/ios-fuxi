#!/bin/bash
set -uo pipefail
L=/root/fuxi/fuxi-fw.log
echo "=== 100-168 行（菜单前后直到结束）==="
awk 'NR>=100 && NR<=168 {printf "%4d| %s\n", NR, substr($0,1,175)}' "$L"

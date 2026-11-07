#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/.cache/xnu-work/makedefs/MakeInc.cmd
echo "=== MakeInc.cmd 里 sysctl/sw_vers 的调用 ==="
grep -n 'sysctl\|sw_vers\|SYSCTL\|physicalcpu\|memsize' "$F" 2>/dev/null | head -15
echo
echo "=== 505..525 行 ==="
sed -n '505,525p' "$F" 2>/dev/null
echo
echo "=== 谁定义了 SYSCTL ==="
grep -rn 'SYSCTL' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/.cache/xnu-work/makedefs/*.cmd 2>/dev/null | head -8

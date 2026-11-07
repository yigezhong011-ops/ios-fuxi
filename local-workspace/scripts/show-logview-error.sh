#!/bin/bash
set -uo pipefail
L=/root/build/unixnu/out/fuxi/logs/firmware.log
[ -f "$L" ] || L=/root/fw2.log
echo "=== 含 AdvancedLogViewLib 的行（带后 2 行）==="
grep -n -A2 'AdvancedLogViewLib' "$L" | grep -vi '^--$' | head -30 | cut -c1-220
echo
echo "=== 所有 clang 报错 ==="
grep -nE '^[^ ]*\.(c|h):[0-9]+:[0-9]+: (error|fatal)' "$L" | head -10 | cut -c1-220

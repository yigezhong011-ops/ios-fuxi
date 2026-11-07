#!/bin/bash
set -uo pipefail
L=/root/build/unixnu/out/fuxi/logs/firmware.log
[ -f "$L" ] || L=/root/fw2.log
n=$(grep -n 'AdvancedLogViewLib' "$L" | grep -i 'error\|fatal' | head -1 | cut -d: -f1)
echo "第一个错误行: ${n:-未找到}"
if [ -n "${n:-}" ]; then
  lo=$(( n > 6 ? n - 6 : 1 ))
  awk -v lo="$lo" -v hi="$(( n + 8 ))" 'NR>=lo && NR<=hi {printf "%4d| %s\n", NR, substr($0,1,200)}' "$L"
else
  grep -nE 'error:|fatal error:|undefined' "$L" | head -12 | cut -c1-200
fi

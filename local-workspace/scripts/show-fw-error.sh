#!/bin/bash
set -uo pipefail
L=/root/fw-full.log
echo "总行数 $(wc -l < "$L")"
n=$(grep -n 'Aborting' "$L" | head -1 | cut -d: -f1)
echo "Aborting 在第 $n 行"
if [ -n "${n:-}" ]; then
  lo=$(( n > 30 ? n - 30 : 1 ))
  awk -v lo="$lo" -v hi="$(( n + 2 ))" 'NR>=lo && NR<=hi {printf "%4d| %s\n", NR, substr($0,1,150)}' "$L"
fi

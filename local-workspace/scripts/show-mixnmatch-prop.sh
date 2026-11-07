#!/bin/bash
set -uo pipefail
W=/root/fuxi/adtcmp
echo "=== 旧 ADT 里 mix-n-match-prevention-status 的节点与值 ==="
if command -v fdtdump >/dev/null 2>&1; then
  fdtdump "$W/theirs.adt" 2>/dev/null | grep -n -B12 'mix-n-match-prevention-status' | head -40
else
  echo "fdtdump 缺失，用 dtc"
  dtc -I dtb -O dts "$W/theirs.adt" 2>/dev/null | grep -n -B10 -A2 'mix-n-match' | head -40
fi

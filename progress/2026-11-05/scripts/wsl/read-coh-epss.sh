#!/bin/bash
# Read the freshly carved strings: coherence state, scanout counters and the FUXI120 rounds.
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-coh2/lscan.txt
echo "=== 文件 $(du -h "$L" | cut -f1) ==="
echo
echo "=== [coherence] 行（最后 8 条）==="
grep -a '\[coherence\]' "$L" | tail -8 | cut -c1-200
echo
echo "=== [scanout prepare] 行（最后 5 条）==="
grep -a '\[scanout prepare\]' "$L" | tail -5 | cut -c1-220
echo
echo "=== FUXI120 行（最后 20 条）==="
grep -a 'FUXI120' "$L" | tail -20 | cut -c1-160
echo
echo "=== 关键字计数 ==="
for k in 'present' 'cadence' 'vsync' 'FUXI120' 'done' 'gpu'; do
  printf '  %-10s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done

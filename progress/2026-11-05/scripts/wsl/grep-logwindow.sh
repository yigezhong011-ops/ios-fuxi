#!/bin/bash
# Search the 32 MiB kernel log window for the pacing and coherence lines.
set -uo pipefail
B=/mnt/e/DSH-Fuxi/logs/carve-coh2/log.bin
echo "=== $(du -h "$B" | cut -f1) ==="
echo
echo "=== [coherence] ==="
tr -d '\0' < "$B" | grep -a -o '\[coherence\][^\n]*' | tail -6 | cut -c1-200
echo
echo "=== [scanout prepare] ==="
tr -d '\0' < "$B" | grep -a -o '\[scanout prepare\][^\n]*' | tail -4 | cut -c1-240
echo
echo "=== FUXI120 ==="
tr -d '\0' < "$B" | grep -a -o 'FUXI120[^\n]*' | tail -12 | cut -c1-160
echo
echo "=== 关键字计数 ==="
for k in coherence FUXI120 scanout cadence; do
  printf '  %-12s %s\n' "$k" "$(tr -d '\0' < "$B" | grep -ac "$k" 2>/dev/null || echo 0)"
done

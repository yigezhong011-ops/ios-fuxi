#!/bin/bash
# Counter check for the A/B run.
set -uo pipefail
D=$(ls -d /root/fuxi/cad-ab/*/ | head -1)
echo "目录 $D"
echo
echo "=== [fence wait] ==="
grep -a '^\[fence wait\] calls' "$D/slots.txt" | tail -1 | cut -c1-210
echo
echo "=== [scanout wait] ==="
grep -a '^\[scanout wait\]' "$D/slots.txt" | tail -1 | cut -c1-210
echo
echo "=== [coherence] ==="
grep -a '^\[coherence\] H' "$D/slots.txt" | tail -1 | cut -c1-220
echo
echo "=== [scanout prepare] ==="
grep -a 'prepare calls=' "$D/slots.txt" | tail -1 | cut -c1-210

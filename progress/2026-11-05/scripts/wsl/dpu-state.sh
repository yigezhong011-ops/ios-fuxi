#!/bin/bash
# DPU status and display state for the A/B run.
set -uo pipefail
D=$(ls -d /root/fuxi/cad-ab/*/ | head -1)
echo "=== [dpu] 最后两条 ==="
grep -a '^\[dpu\]' "$D/slots.txt" | tail -2 | cut -c1-220
echo
echo "=== [dpu pipes0/1] 最后两条 ==="
grep -a '^\[dpu pipes' "$D/slots.txt" | tail -4 | cut -c1-200
echo
echo "=== [display state] 最后两条 ==="
grep -a -A1 '^\[display state\]' "$D/slots.txt" | tail -4 | cut -c1-160
echo
echo "=== scanout wait 的时间分布（若有多条）==="
grep -a '^\[scanout wait\]' "$D/slots.txt" | head -3 | cut -c1-200

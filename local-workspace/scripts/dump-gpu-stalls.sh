#!/bin/bash
# GPU-side stall evidence from the decoded slots.
set -uo pipefail
D=/root/fuxi/cad2/untagged-42562c5a
echo "=== [fence wait] 样本（最后 2 组）==="
grep -a -A3 '^\[fence wait\]' "$D/slots.txt" | tail -8 | cut -c1-200
echo
echo "=== [stall] 样本（最后 2 组）==="
grep -a -A3 '^\[stall\]' "$D/slots.txt" | tail -8 | cut -c1-200
echo
echo "=== [wait port] 样本（最后 2 组）==="
grep -a -A3 '^\[wait port\]' "$D/slots.txt" | tail -6 | cut -c1-200
echo
echo "=== [ring] / [ib] 样本 ==="
grep -a -A2 '^\[ring\]' "$D/slots.txt" | tail -4 | cut -c1-200
grep -a -A2 '^\[ib\]' "$D/slots.txt" | tail -4 | cut -c1-200

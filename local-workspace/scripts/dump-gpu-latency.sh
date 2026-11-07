#!/bin/bash
# GPU job latency and completion stats from the same boot.
set -uo pipefail
D=/root/fuxi/cad2/untagged-42562c5a
echo "=== [gpu] 段（最后 3 组）==="
grep -a -A4 '^\[gpu\]' "$D/slots.txt" | tail -12 | cut -c1-200
echo
echo "=== 含 gpu 的统计行（去重，前 15）==="
grep -a -iE '^\[' "$D/slots.txt" | grep -a -iE 'gpu|fence|completion' | sed 's/^\[//' | sed 's/\].*//' | sort -u | head -15
echo
echo "=== [reset] / coherence 段 ==="
grep -a -A2 '^\[reset\]' "$D/slots.txt" | tail -4 | cut -c1-160
grep -a 'coherence' "$D/slots.txt" | tail -2 | cut -c1-160

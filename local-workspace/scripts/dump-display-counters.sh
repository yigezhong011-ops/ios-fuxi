#!/bin/bash
# Dump one [display] block and the scanout counters from the newest carve's slots.
set -uo pipefail
D=/root/fuxi/cad2/untagged-42562c5a
[ -d "$D" ] || { echo "没有解码目录"; exit 1; }
echo "=== [display state] 与 [scanout prepare]（最后 3 组）==="
grep -a -A1 '^\[display state\]' "$D/slots.txt" | tail -6 | cut -c1-160
echo
echo "=== [scanout prepare] 计数器的变化（前 3 与后 3）==="
grep -a 'prepare calls=' "$D/slots.txt" | sed -n '1,3p;$p' | cut -c1-200
echo
echo "=== IOMFB 里的刷新率相关字段（去重）==="
grep -ao 'displayMinRefreshInterval[^<]*<integer[^>]*>[^<]*' "$D/slots.txt" | sort -u | head -5
grep -ao 'displayMaxRefreshInterval[^<]*<integer[^>]*>[^<]*' "$D/slots.txt" | sort -u | head -5
echo
echo "=== 每次快照里 IOMFB 的 swap 计数（若有）==="
grep -ao 'Last Swaps Array[^]]*]' "$D/slots.txt" | head -3 | cut -c1-200

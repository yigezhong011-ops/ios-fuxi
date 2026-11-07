#!/bin/bash
# How do submit/complete drift over the boot?
set -uo pipefail
D=/root/fuxi/cad2/untagged-42562c5a
echo "=== 所有 coherence 行（前 3 与后 3）==="
grep -a '^\[coherence\] H' "$D/slots.txt" | sed -n '1,3p' | cut -c1-230
echo '   ...'
grep -a '^\[coherence\] H' "$D/slots.txt" | tail -3 | cut -c1-230
echo
echo "=== submit / complete 的比例（最后一条）==="
last=$(grep -a '^\[coherence\] H' "$D/slots.txt" | tail -1)
echo "$last" | grep -o 'submit=[0-9]* complete=[0-9]*' | while read -r line; do
  s=$(echo "$line" | sed 's/submit=\([0-9]*\).*/\1/')
  c=$(echo "$line" | sed 's/.*complete=\([0-9]*\)/\1/')
  echo "  submit=$s complete=$c 完成率 $(echo "$s $c" | awk '{printf "%.1f%%", $2*100/$1}')"
done

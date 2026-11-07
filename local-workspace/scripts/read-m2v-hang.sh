#!/bin/bash
# Read only: GPU progress and faults in COM3 logs of the branch plugin runs. Usage: read-m2v-hang.sh <log names...>
C=/mnt/e/DSH-Fuxi/logs
for f in "$@"; do
  echo "=== $f"; tr -d '\r' < $C/$f > /tmp/h.txt; wc -l < /tmp/h.txt
  grep -a 'FUXI120S' /tmp/h.txt | tail -9 | cut -c1-90
  grep -a 'FUXI120R' /tmp/h.txt | tail -1 | cut -c1-110
  echo '--- faults'
  grep -a -i -E 'fault|hang|timeout|timed out|recover|context lost|lost|stuck|wedge|crash|exc_|jetsam|killed|reset|abort' /tmp/h.txt | grep -v -E 'FUXI120|autoreset|default|Default' | sed -E 's/^\[?[ 0-9.]+\]? ?//; s/0x[0-9a-f]+/N/g; s/\b[0-9]+\b/N/g' | cut -c1-120 | sort | uniq -c | sort -rn | head -14
done

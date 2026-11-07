#!/bin/bash
# What the poster processes and the black g7grant boot did, from COM3. Read-only.
C=/mnt/e/DSH-Fuxi/logs
for f in com3-t50-auto-g7grant-104931.log com3-t50-auto-g7plugrant-105313.log; do
  echo "=== $f $(wc -l < $C/$f) lines"
  tr -d '\r' < $C/$f > /tmp/c.txt
  grep -a -c 'boot-args' /tmp/c.txt
  grep -a -o -E 'boot-args = .{0,40}' /tmp/c.txt | head -1
  echo '--- poster and gpu trouble'
  grep -a -i -E 'KaleidoscopePost|PridePosterExt|HelloPosterExt|e00002d5|native-metal|EXC_|Corpse|jetsam|SIGABRT|GPU|verify_swap|backboardd' /tmp/c.txt | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9]+/N/g' | cut -c1-110 | sort | uniq -c | sort -rn | head -22
  echo '--- tail'; tail -5 /tmp/c.txt | cut -c1-120
done

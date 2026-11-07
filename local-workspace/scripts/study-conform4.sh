#!/bin/bash
# Read-only: the two getResourceValue callers in PosterBoardServices, in full.
for a in 0x1a82dbd0c 0x1a82e0a60; do
  L=$(grep -n "^$a " /tmp/pbs.txt | cut -d: -f1)
  echo "=== $a"
  sed -n "$((L-60)),$((L+70))p" /tmp/pbs.txt | cut -c1-100 | grep -E 'bl\s|ret$|tbz|tbnz|cbz|cbnz|"|NS|\[' | head -60
done

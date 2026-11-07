#!/bin/bash
set -uo pipefail
for L in /root/local-build.log /root/local-serial.log; do
  echo "=== $L ($(wc -l < "$L" 2>/dev/null) 行) ==="
  tail -25 "$L" 2>/dev/null | cut -c1-175
  echo
done

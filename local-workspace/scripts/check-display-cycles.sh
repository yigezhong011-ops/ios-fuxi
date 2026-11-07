#!/bin/bash
set -uo pipefail
for d in mon36 mon37; do
  L=/root/fuxi/$d/boot.log
  [ -f "$L" ] || continue
  echo "=== $d ==="
  tr -d '\000' < "$L" | grep -a 'SWEET FB: display' | head -4
  tr -d '\000' < "$L" | grep -a -i 'backlight' | tail -3
  echo
done

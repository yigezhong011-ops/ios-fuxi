#!/bin/bash
set -uo pipefail
for n in mon54 mon54b; do
  L=/root/fuxi/$n/boot.log
  [ -f "$L" ] || continue
  echo "=== $n ==="
  printf 'exec=%s SpringBoard=%s swaps=%s scanout=%s poster_crash=%s\n' \
    "$(tr -d '\000' < "$L" | grep -a -c '^exec ')" \
    "$(tr -d '\000' < "$L" | grep -a -c 'exec SpringBoard')" \
    "$(tr -d '\000' < "$L" | grep -a -c 'SWEET FB: swap')" \
    "$(tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -1 | cut -d= -f2)" \
    "$(tr -d '\000' < "$L" | grep -a -c 'CRASH.*Poster')"
  tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -2
done

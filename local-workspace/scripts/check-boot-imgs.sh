#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
for img in boot-gpu3-v4.img boot-touch-v4.img boot-final-v4.img boot-native-v4.img; do
  echo "=== $img ==="
  strings -a "$P/$img" | grep -m1 -o 'debug=0x[0-9a-f]*.*sweetfb_hz=[0-9]*' | cut -c1-220
  echo
done
echo "=== ADT 里的 root extents（fuxi-root.adt）==="
strings -a "$P/fuxi-root.adt" | grep -i -A1 'root' | head -6

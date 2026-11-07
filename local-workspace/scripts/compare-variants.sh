#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
for img in boot-gpu3-cpus6.img boot-gpu3-cool.img boot-gpu3-cool2.img; do
  echo "=== $img ==="
  strings -a "$P/$img" | grep -m1 -o 'debug=0x[0-9a-f]*.*sweetfb_hz=[0-9]*' | tr ' ' '\n' | grep -E 'sweetexecswap|sweetfb_hz|cpus=' | sed 's/^/  /'
done

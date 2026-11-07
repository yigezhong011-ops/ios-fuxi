#!/bin/bash
set -uo pipefail
for img in /mnt/e/DSH-Fuxi/fuxi-csfix-quiet.img /mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/boot-gpu3-cpus6.img; do
  echo "=== $(basename $img) ==="
  strings -a "$img" | grep -oE 'debug=0x[0-9a-f]+[^"]*' | head -1 | tr ' ' '\n' | sed 's/^/  /'
  echo
done

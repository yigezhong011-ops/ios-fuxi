#!/bin/bash
set -uo pipefail
for img in /mnt/e/DSH-Fuxi/fuxi-ownkernel-log.img /mnt/e/DSH-Fuxi/fuxi-metal-arrearm.img; do
  echo "=== $(basename $img) ==="
  strings -a "$img" | grep -oE 'debug=0x[0-9a-f]*[^"]*' | head -1 | tr ' ' '\n' | grep -E 'fuxibbgpu|boot-uuid|cpus=|noconsole|ufsroot' | sed 's/^/  /'
  echo
done

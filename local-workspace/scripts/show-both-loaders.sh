#!/bin/bash
# Print loader / dtb / volume identity for the two built images.
set -uo pipefail
for f in /mnt/e/DSH-Fuxi/t36-bl2-gpu-fix.img /mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py "$f" 2>&1 | tail -1
done

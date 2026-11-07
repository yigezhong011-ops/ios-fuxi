#!/bin/bash
# Compare the loader/tree of the t50 bases and the repacked image.
set -uo pipefail
for f in /mnt/e/DSH-Fuxi/t50-mine.img \
         /mnt/e/DSH-Fuxi/t50-subtype2556-nodiag.img \
         /mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img; do
  echo "--- $(basename "$f") ($(stat -c%s "$f") 字节) ---"
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py "$f" 2>&1 | tail -2
done

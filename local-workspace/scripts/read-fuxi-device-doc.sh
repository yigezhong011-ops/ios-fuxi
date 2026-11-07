#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
echo "=== devices 目录里的 fuxi 相关 ==="
ls "$D/devices" 2>/dev/null | grep -i fuxi
echo
for f in "$D"/devices/fuxi*.md; do
  [ -f "$f" ] || continue
  echo "=== $(basename "$f") 的 State / GPU 段 ==="
  grep -n -A8 -i 'state\|gpu\|accelerat' "$f" 2>/dev/null | head -30
  echo
done

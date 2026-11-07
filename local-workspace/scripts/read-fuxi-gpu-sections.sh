#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs/devices/fuxi-mouse233.md
echo "=== GPU 段 ==="
awk '/^## GPU/,/^## [^G]/' "$F" | head -40
echo
echo "=== Display 段 ==="
awk '/^## Display/,/^## [^D]/' "$F" | head -25
echo
echo "=== 提到 gpu/adreno/zap/固件 的行 ==="
grep -n -i 'gpu\|adreno\|zap\|gmu\|firmware' "$F" | head -25

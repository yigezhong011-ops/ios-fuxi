#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build
echo "=== 需要的脚本是否存在 ==="
for p in \
  "unixnu/scripts/build-adreno-metal-plugin.py" \
  "unixnu/scripts/make-owner-trust-bundle.py" \
  "uefi-fuxi/scripts/bootimage.py" \
  "fuxi/scripts/build-adreno-metal-plugin.py" \
  "fuxi/scripts/make-owner-trust-bundle.py" ; do
  if [ -f "$B/$p" ]; then echo "  ✓ $p"; else echo "  ✗ $p"; fi
done
echo
echo "=== unixnu/scripts 下的相关脚本 ==="
ls "$B/unixnu/scripts" 2>/dev/null | grep -iE 'adreno|trust|gpu|data|payload|metal' | head -20
echo
echo "=== fuxi/scripts ==="
ls "$B/fuxi/scripts" 2>/dev/null | head -20
echo
echo "=== uefi-fuxi/scripts ==="
ls "$B/uefi-fuxi/scripts" 2>/dev/null | head -10

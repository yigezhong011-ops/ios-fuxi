#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs/devices
echo "=== 文件大小 ==="
wc -l "$D"/fuxi*.md 2>/dev/null
echo
echo "=== fuxi-ljhhkx529.md ==="
cat "$D/fuxi-ljhhkx529.md" 2>/dev/null | head -60

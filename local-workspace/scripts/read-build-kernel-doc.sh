#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
f=$D/guide/build-kernel.md
echo "=== $f ==="
wc -l "$f" 2>/dev/null
sed -n '1,120p' "$f" 2>/dev/null

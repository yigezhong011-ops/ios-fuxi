#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
f=$(ls "$D"/porting/gpu.md 2>/dev/null || find "$D" -name 'gpu*.md' | head -1)
echo "=== 文档: $f ==="
sed -n '1,90p' "$f" 2>/dev/null

#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
f=$D/porting/migration.md
echo "=== migration.md 里的 build-inputs 段 ==="
awk '/[Bb]uild inputs/,0' "$f" | head -70

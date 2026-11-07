#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs/drivers
echo "=== drivers 目录 ==="
ls "$D" 2>/dev/null
echo
echo "=== adreno740.md 里的 boot 参数 ==="
grep -n 'sheng-gpu\|sheng-fb\|client window\|NoSpace\|publish' "$D/adreno740.md" 2>/dev/null | head -25

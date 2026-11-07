#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs/drivers
echo "=== adreno740.md（前 90 行）==="
sed -n '1,90p' "$D/adreno740.md"

#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== verify_source ==="
sed -n '/def verify_source/,/^def /p' "$T/scripts/fuxi_adreno_common.py" | head -24 | cut -c1-170
echo
echo "=== prepare() 里 load_pins/verify_source 的调用 ==="
sed -n '80,100p' "$T/scripts/prepare-fuxi-gmu.py" | cut -c1-170

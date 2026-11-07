#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== ensure_fuxi_firmware ==="
sed -n '/def ensure_fuxi_firmware/,/^def /p' "$T/scripts/fuxi_adreno_common.py" | head -30 | cut -c1-170
echo
echo "=== build-adreno740-kits.py 里的固件调用 ==="
grep -n 'firmware\|ensure_fuxi\|cache' "$T/scripts/build-adreno740-kits.py" 2>/dev/null | head -10 | cut -c1-170

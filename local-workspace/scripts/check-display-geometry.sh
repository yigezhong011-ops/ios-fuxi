#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device
echo "=== board.toml 里的显示几何 ==="
grep -n -i 'width\|height\|stride\|panel\|1080\|2400\|display' board.toml | head -16 | cut -c1-170
echo
echo "=== fuxi-adreno-inputs / sheng-display-inputs 里的几何 ==="
grep -n -i 'stride\|width\|height\|1080\|2400' scripts/data/sheng-display-inputs.json 2>/dev/null | head -10 | cut -c1-170

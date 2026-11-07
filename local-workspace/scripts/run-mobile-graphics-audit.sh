#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
cd "$T" || exit 1
echo "=== 运行 audit-mobile-graphics-legacy.py ==="
python3 scripts/audit-mobile-graphics-legacy.py 2>&1 | tail -12 | cut -c1-170
echo
echo "=== 产物 ==="
ls -l build/display-analysis/ 2>/dev/null | head -5

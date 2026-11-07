#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/docs-lanes/metal-m9n.md
echo "=== 74-90 行 ==="
sed -n '74,90p' "$D"
echo
echo "=== 176-203 行（下一步）==="
sed -n '176,203p' "$D"

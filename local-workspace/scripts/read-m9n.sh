#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/docs-lanes/metal-m9n.md
echo "=== 规模 ==="; wc -l "$D"
echo "=== 小标题 ==="; grep -n '^#' "$D" | head -15
echo
echo "=== 550 / XR / 建议 ==="
grep -n -i -A6 '550\|XR10\|two-plane' "$D" | head -40

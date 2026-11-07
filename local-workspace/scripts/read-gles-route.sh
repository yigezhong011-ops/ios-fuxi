#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/docs-lanes/metal-gles-route.md
echo "=== 标题结构 ==="
grep -n '^#' "$D" | head -25
echo
echo "=== 前 70 行 ==="
sed -n '1,70p' "$D"

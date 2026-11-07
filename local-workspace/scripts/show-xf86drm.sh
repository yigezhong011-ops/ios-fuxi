#!/bin/bash
set -uo pipefail
H=/mnt/e/DSH-Fuxi/mesa-ios/vendor/redwood-drm/xf86drm.h
echo "=== 行数 ==="; wc -l "$H"
echo "=== 内容概览（非空行前 40 行）==="
grep -v '^\s*$' "$H" | head -40

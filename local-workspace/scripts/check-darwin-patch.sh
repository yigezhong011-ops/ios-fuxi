#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/mesa-ios/vendor/patches/freedreno-darwin.patch
echo "=== 补丁里对 redwood-drm 的引用 ==="
grep -n 'redwood-drm' "$P" | head -20
echo "=== 补丁改动的文件列表 ==="
grep -n '^+++ \|^--- ' "$P" | head -20

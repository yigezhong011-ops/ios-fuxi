#!/bin/bash
set -uo pipefail
R=/mnt/e/DSH-Fuxi/mesa-ios/vendor/redwood-drm/redwood_drm.c
echo "=== NONE 宏与存根定义 ==="
grep -n -A3 '#define NONE' "$R"
grep -n 'NONE(drm' "$R"
echo
echo "=== redwood_drm_surface 签名 ==="
grep -n -B4 -A6 'redwood_drm_surface' "$R" | head -30
echo
echo "=== xf86drm.h 里的 redwood_drm_surface 结构 ==="
grep -n -B2 -A12 'redwood_drm_surface' /mnt/e/DSH-Fuxi/mesa-ios/vendor/redwood-drm/xf86drm.h

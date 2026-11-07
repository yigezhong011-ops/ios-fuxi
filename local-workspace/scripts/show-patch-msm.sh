#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/mesa-ios/vendor/patches/freedreno-darwin.patch
echo "=== msm_priv.h 的改动（看它要什么头）==="
sed -n '86,140p' "$P"
echo
echo "=== freedreno/drm/meson.build 改动 ==="
sed -n '64,86p' "$P"

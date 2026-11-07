#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-scanout/SweetSurface.cpp
S=$(grep -n 'int sweet_surface_gpu_copy' "$F" | cut -d: -f1)
echo "start line $S"
sed -n "${S},$((S+70))p" "$F"

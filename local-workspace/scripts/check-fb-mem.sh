#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== fPhys / fPixels 的来源 ==="
grep -n 'fPhys\s*=\|fPixels\s*=\|sweet-fbcon\|fbcon\|reg\b' "$F" | head -20
echo
echo "=== 面板扫描地址（DPU）==="
grep -n 'G4_FB_PA\|0xae05014\|scanout\|SCANOUT' "$F" | head -15

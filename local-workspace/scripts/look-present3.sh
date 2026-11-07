#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
S=$(grep -n 'AppleCLCD::present(const uint8_t' "$F" | cut -d: -f1)
echo "present at line $S"
sed -n "$((S+100)),$((S+190))p" "$F"

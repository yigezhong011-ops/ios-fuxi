#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
START=$(grep -n 'AppleCLCD::present(const uint8_t \*rec)' "$F" | cut -d: -f1)
echo "present() starts at line $START"
sed -n "${START},$((START+160))p" "$F"

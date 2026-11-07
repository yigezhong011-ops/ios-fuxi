#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== present() 实现 ==="
awk '/AppleCLCD::present\(/,/^}/' "$F" | head -80
echo
echo "=== swap() 实现 ==="
awk '/AppleCLCD::swap\(/,/^}/' "$F" | head -40

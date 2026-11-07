#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== 完成/回调 相关 ==="
grep -n -i 'complete\|notify\|callback\|swapdone\|swapComplete\|fence' "$F" | head -25
echo
echo "=== swap() 全文 ==="
S=$(grep -n 'AppleCLCD::swap(const uint8_t' "$F" | cut -d: -f1)
sed -n "$S,$((S+45))p" "$F"

#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-h1/SweetHID.cpp
echo "=== touch() 方法实现 ==="
grep -n 'touch(' "$F" | head -10
echo "---"
sed -n "$(grep -n 'void.*touch(int' "$F" | head -1 | cut -d: -f1),+80p" "$F"

#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
F=$(find . -name 'SweetFramebuffer.cpp' | head -1)
echo "file: $F"
echo "=== 关键函数/地址/拷贝 ==="
grep -n -E 'memcpy|bcopy|0xb8000000|framebuffer|present|swap|copy|panel|rowBytes|stride' "$F" | head -40

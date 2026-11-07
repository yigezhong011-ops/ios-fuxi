#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== 呈现/拷贝相关函数 ==="
grep -n 'presentLocked\|copyPresent\|blit\|memcpy\|fLogicalW\|fLogicalH\|fWidth\|fHeight' "$F" | head -30
echo
echo "=== copy 循环上下文 ==="
grep -n -B4 -A20 'copy avg' "$F" | head -40

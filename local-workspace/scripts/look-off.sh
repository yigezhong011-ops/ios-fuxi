#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-unixnu/SweetFramebuffer.cpp
echo "=== display off 的打印处及上下文 ==="
grep -n 'display off' "$F"
L=$(grep -n 'display off' "$F" | head -1 | cut -d: -f1)
[ -n "$L" ] && sed -n "$((L-30)),$((L+30))p" "$F"
echo
echo "=== presentWanted / idle 相关 ==="
grep -n 'presentWanted\|fUnixnuIdle\|idleTimer\|AutoLock\|autolock' "$F" | head -20

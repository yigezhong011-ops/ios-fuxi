#!/bin/bash
set -uo pipefail
echo "=== 仓库里关于解锁/跳过锁屏的开关 ==="
grep -rn -i 'unlock\|lockscreen\|lock_screen\|auto-unlock\|swipe' /root/ios-fuxi/xnu/fuxi-h1/*.c /root/ios-fuxi/xnu/fuxi-exec/*.c 2>/dev/null | head -12
echo
echo "=== sweet-root-tweaks 里的 springboard 偏好 ==="
grep -n -A12 "com.apple.springboard" /root/ios-fuxi/tools/sweet-root-tweaks.py | head -20
echo
echo "=== docs 里提解锁的地方 ==="
grep -rn -i 'swipe up to unlock\|unlock' /root/ios-fuxi/docs/sweet.md /root/ios-fuxi/docs-lanes/*.md 2>/dev/null | head -8

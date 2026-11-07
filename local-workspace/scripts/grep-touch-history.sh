#!/bin/bash
set -uo pipefail
echo "=== STATUS.md 里触摸相关 ==="
grep -n -i 'touch' /mnt/e/DSH-Fuxi/STATUS.md | head -20
echo
echo "=== 内核里触摸供电的实现（其他地方）==="
grep -rn -i 'ldob12\|ldom6' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.patch' | head -10

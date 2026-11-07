#!/bin/bash
set -uo pipefail
echo "=== console.h 接口 ==="
cat /root/ios-fuxi/shim/console.h
echo
echo "=== console.c 里是否有 printf 风格输出 ==="
grep -n 'void \|int ' /root/ios-fuxi/shim/console.c | head -12

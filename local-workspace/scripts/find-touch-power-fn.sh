#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-probe/probe.c
echo "=== 触摸上电函数（TP 分支附近）==="
sed -n '700,780p' "$F"
echo
echo "=== 相关函数定义 ==="
grep -n 'static.*touch_\|void touch_\|int touch_' "$F" | head -12

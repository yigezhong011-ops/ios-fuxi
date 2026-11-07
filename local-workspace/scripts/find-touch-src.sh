#!/bin/bash
set -uo pipefail
echo "=== 谁打印 'touch detection mode' ==="
grep -rn 'touch detection mode' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.patch' | head -5
grep -rln 'touch detection mode' /root/ios-fuxi/xnu/patches/*.patch 2>/dev/null | head -3
echo
echo "=== 触摸模块的 boot-arg（在整个仓库里找）==="
grep -rn 'fuxitouch\|touchscreen=\|sweettouch' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.patch' | head -10
echo
echo "=== xnu 目录结构 ==="
ls /root/ios-fuxi/xnu/

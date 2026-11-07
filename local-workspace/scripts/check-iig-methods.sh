#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
H=$T/build/xnu/obj/DEVELOPMENT_ARM64_BCM2837/iokit/DriverKit/IOService.h
echo "=== 生成头里有没有这两个方法 ==="
grep -n 'UserSetProperties\|SendIOMessageServicePropertyChange' "$H" 2>/dev/null | head -6 || echo "  （都没有）"
echo
echo "=== .iig 里 465-490 行（声明上下文）==="
sed -n '465,495p' "$T/.cache/xnu-work/iokit/DriverKit/IOService.iig" | sed 's/^/  /'
echo
echo "=== 生成头里 LOCAL 方法的处理方式（搜一个已知 LOCAL 方法）==="
grep -n '_Impl' "$H" 2>/dev/null | head -8

#!/bin/bash
set -uo pipefail
E=/mnt/e/DSH-Fuxi/mesa-ios/userland/eagl.c
echo "=== 构造器 / swizzle 入口 ==="
grep -n 'constructor\|__attribute__((constructor))\|class_replaceMethod\|method_exchangeImplementations\|objc_getClass\|+load' "$E" | head -20
echo
echo "=== 桥里出现的 Apple 类名 ==="
grep -o 'EAGL[A-Za-z]*\|CAEAGL[A-Za-z]*' "$E" | sort -u | head -10
echo
echo "=== 是否有 dyld 注入相关的环境变量处理 ==="
grep -n 'getenv\|DYLD_' "$E" | head -10

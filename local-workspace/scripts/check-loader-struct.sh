#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-loader/loader.c
echo "=== loader.c 规模 ==="
wc -l "$F"
echo
echo "=== 主要函数 ==="
grep -n '^[a-z].*(' "$F" | head -20
echo
echo "=== 打印/日志函数 ==="
grep -n 'printf\|puts\|uart_puts' "$F" | head -8
echo
echo "=== main 入口 ==="
grep -n -A25 'int main\|void main\|_start' "$F" | head -40

#!/bin/bash
set -uo pipefail
M=/root/ios-fuxi/tools/fuxi-xnu-monitor.py
echo "=== 监控的请求类型 ==="
grep -n 'def request\|0x4e\|0x42\|0x54\|0x5[0-9a-f]\|read' "$M" | head -25
echo
echo "=== request 函数与 RAM 窗口读取 ==="
grep -n -B3 -A12 'def request' "$M" | head -30

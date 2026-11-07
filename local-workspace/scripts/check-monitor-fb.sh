#!/bin/bash
set -uo pipefail
M=/root/ios-fuxi/tools/fuxi-xnu-monitor.py
echo "=== 监控抓 framebuffer 的地址来源 ==="
grep -n -B4 -A10 'framebuffer' "$M" | head -45

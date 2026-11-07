#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-h1
echo "=== 触控驱动文件 ==="
ls -l "$D"/*touch* 2>/dev/null
echo
echo "=== 报告解析里坐标更新的地方 ==="
grep -n 'x\s*=\|y\s*=\|moved\|down at\|up at\|pos' "$D"/fuxi_touch.c 2>/dev/null | head -40

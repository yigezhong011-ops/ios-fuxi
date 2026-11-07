#!/bin/bash
set -uo pipefail
F=/root/ux2/fuxi/tree/kits/sheng/BootProgress.c
awk 'NR>=1070 && NR<=1100 {printf "%4d| %s\n", NR, $0}' "$F"
echo
echo "=== 相关宏定义 ==="
grep -n '#define.*(' "$F" | awk -F: '$1>1000 && $1<1090' | head -8

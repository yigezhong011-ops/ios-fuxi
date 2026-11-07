#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg
echo "=== fuxi.fdf 里的日志/工具驱动 ==="
grep -n -iE 'Log|Advanced|Tools|Menu' "$P/fuxi.fdf" 2>/dev/null | head -15 | cut -c1-150
echo
echo "=== fuxi.dsc 里的日志组件 ==="
grep -n -iE 'Log|Advanced' "$P/fuxi.dsc" 2>/dev/null | head -12 | cut -c1-150
echo
echo "=== DXE.inc 里 UFS_STACK 加载的驱动 ==="
awk 'NR>=25 && NR<=100 {printf "%4d| %s\n", NR, $0}' "$P/Include/DXE.inc" 2>/dev/null | grep -E 'INF|!if|!endif' | head -25 | cut -c1-130

#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
echo "=== 工具链里有没有 sysctl / sw_vers 的 shim ==="
ls "$B/scripts/linux/" | sort
echo
echo "=== 源码里对 sw_vers / hw.memsize 的处理 ==="
grep -rn 'sw_vers\|hw.memsize\|physicalcpu\|logicalcpu' "$B/scripts/linux/" "$B/scripts/unixnu/" 2>/dev/null | head -12
echo
echo "=== 文档里讲 Linux 构建的部分 ==="
ls "$B/docs" 2>/dev/null | head -20
grep -rln -i 'linux' "$B/docs" 2>/dev/null | head -8

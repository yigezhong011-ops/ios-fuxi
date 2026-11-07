#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== 谁用 -xc 编译 BootProgress.c ==="
grep -rn "'-xc'\|\"-xc\"" "$D/scripts" 2>/dev/null | head -6 | cut -c1-160
echo
echo "=== 检查脚本里对 BootProgress 的引用 ==="
grep -rln 'BootProgress.c' "$D/scripts" 2>/dev/null | head -6

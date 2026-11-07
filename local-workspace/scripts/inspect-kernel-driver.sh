#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu
echo "=== kernel.py 里 SETUP / 主机编译器的处理 ==="
grep -n 'SETUP\|HOST_CC\|host_cc\|CC=\|KERNEL_CC\|CROSS_CLANG\|DARWIN_TRIPLE' "$D/kernel.py" 2>/dev/null | head -25
echo
echo "=== 有没有提到 SETUP 的注释 ==="
grep -rn -i 'setup tool\|SETUP/\|host compiler' "$D"/*.py 2>/dev/null | head -10

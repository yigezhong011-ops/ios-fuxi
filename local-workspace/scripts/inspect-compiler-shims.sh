#!/bin/bash
set -uo pipefail
echo "=== /usr/bin 的 clang / cc 是什么 ==="
ls -l /usr/bin/clang /usr/bin/cc /usr/bin/clang++ 2>/dev/null
echo
echo "=== scripts/linux/clang 内容 ==="
sed -n '1,40p' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/clang 2>/dev/null
echo
echo "=== scripts/linux/cc 内容 ==="
sed -n '1,40p' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/cc 2>/dev/null

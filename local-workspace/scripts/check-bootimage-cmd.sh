#!/bin/bash
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu
echo "=== 源码里有没有 bootimage ==="
grep -rn 'bootimage' . 2>/dev/null | head -10
echo
echo "=== 子命令注册 ==="
grep -rn 'add_parser(' scripts 2>/dev/null | head -20
echo
echo "=== build 的帮助 ==="
timeout 60 ./unixnu build --help 2>&1 | head -20

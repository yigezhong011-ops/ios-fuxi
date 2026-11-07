#!/bin/bash
set -uo pipefail
L=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/logs/kernel-bootstrap.log
echo "=== 日志里出现的编译器 ==="
grep -oE '/(usr/bin|root/.local/xnu-linux/bin)/[a-z0-9+-]*clang[a-z0-9+-]*' "$L" 2>/dev/null | sort | uniq -c | head
echo
echo "=== 是否提到 host-clang ==="
grep -c 'host-clang' "$L" 2>/dev/null || echo 0
echo
echo "=== replacecontents 的完整编译命令（如果有 -v 或 V=1）==="
grep -n 'replacecontents.c' "$L" 2>/dev/null | head -3
echo
echo "=== kernel.py 是否透传环境 ==="
grep -n 'env=\|os.environ' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py | head -8

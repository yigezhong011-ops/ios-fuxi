#!/bin/bash
set -uo pipefail
echo "=== 内核构建日志尾部 ==="
tail -8 /root/kernel-build.log 2>/dev/null || echo "（无日志）"
echo
echo "=== 编译进程数 ==="
ps -eo pid,cmd 2>/dev/null | grep -c clang
echo
echo "=== 内核产物 ==="
ls -lh /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/kernel/ 2>/dev/null | head -6 || echo "（还没产物）"
echo
echo "=== bootstrap 日志尾部 ==="
L=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/logs/kernel-bootstrap.log
wc -l "$L" 2>/dev/null
tail -4 "$L" 2>/dev/null

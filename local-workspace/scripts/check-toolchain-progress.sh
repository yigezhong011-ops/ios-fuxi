#!/bin/bash
set -uo pipefail
echo "=== 编译进程 ==="
ps aux 2>/dev/null | grep -E 'cmake|ninja|cc1|clang|git ' | grep -v grep | head -6
echo
echo "=== /opt/unixnu-linux ==="
ls /opt/unixnu-linux 2>/dev/null | head -10
du -sh /opt/unixnu-linux 2>/dev/null || echo "（还没有）"
echo
echo "=== 磁盘 ==="
df -h / | tail -1
echo
echo "=== 工作目录（构建树）==="
du -sh /opt/unixnu-linux/build 2>/dev/null || ls /tmp | grep -i unix | head -5

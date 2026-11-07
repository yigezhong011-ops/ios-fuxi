#!/bin/bash
set -uo pipefail
U=/root/userdata-build.log
K=/root/kernel-build.log
echo "=== userdata 构建（日志尾部）==="
if [ -f "$U" ]; then wc -l < "$U" | tr -d '\n'; echo " 行"; tail -8 "$U"; else echo "  还没日志"; fi
echo
echo "=== IPSW 下载情况 ==="
du -sh /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/ipsw 2>/dev/null
ls -lh /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/ipsw/21H461/ 2>/dev/null | head -8
echo
echo "=== 内核构建进程 ==="
ps -eo pid,etime,cmd 2>/dev/null | grep -E 'clang|make|unixnu' | grep -v grep | wc -l
echo
echo "=== 内核产物 ==="
ls -lh /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/kernel/ 2>/dev/null | head -5
echo
echo "=== 磁盘 ==="
df -h / | tail -1

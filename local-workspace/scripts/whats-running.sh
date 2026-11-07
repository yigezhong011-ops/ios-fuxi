#!/bin/bash
set -uo pipefail
echo "=== setup-toolchain 进程 ==="
ps -eo pid,etime,cmd 2>/dev/null | grep -E 'setup-toolchain|cmake|ninja|make|curl|wget|git|cc1' | grep -v grep | head -10
echo
echo "=== 最近修改的文件（/opt/unixnu-linux）==="
find /opt/unixnu-linux -newermt '-10 minutes' -type f 2>/dev/null | head -8
echo
echo "=== /tmp 下的构建目录 ==="
ls -lt /tmp 2>/dev/null | head -6

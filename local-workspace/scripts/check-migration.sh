#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon27/boot.log
echo "=== 迁移相关日志 ==="
tr -d '\000' < "$L" | grep -a -i 'migrat\|datamigrator\|setupdone\|firstboot' | head -12
echo
echo "=== launchd 启动的服务数（exec 总数）==="
tr -d '\000' < "$L" | grep -a -c '^exec '
echo
echo "=== 是否有卡死/超时迹象 ==="
tr -d '\000' < "$L" | grep -a -i 'timeout\|hang\|watchdog\|stall' | head -8
echo
echo "=== 最后 5 个不重复的 exec ==="
tr -d '\000' < "$L" | grep -a '^exec ' | tail -5

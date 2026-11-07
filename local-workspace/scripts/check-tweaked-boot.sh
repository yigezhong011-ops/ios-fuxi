#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon28/boot.log
echo "=== 迁移是否还在跑 ==="
tr -d '\000' < "$L" | grep -a -c 'datamigrator\|migrationplugin' || true
echo
echo "=== Setup / buddy ==="
tr -d '\000' < "$L" | grep -a -i 'purplebuddy\|setupdone\|SetupAssistant' | head -5
echo
echo "=== exec 的最后 10 个 ==="
tr -d '\000' < "$L" | grep -a '^exec ' | tail -10
echo
echo "=== 崩溃统计 ==="
tr -d '\000' < "$L" | grep -a -o 'CRASH [A-Za-z0-9._-]*' | sort | uniq -c | sort -rn | head -6
echo
echo "=== 最后 10 行 ==="
tr -d '\000' < "$L" | grep -av 'SWEET DBG' | grep -av 'matching1' | tail -10

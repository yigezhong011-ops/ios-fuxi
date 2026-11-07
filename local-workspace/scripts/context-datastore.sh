#!/bin/bash
# What surrounds the poster data-store failure? Protection class? Permissions?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
n=$(grep -an -m 1 'could not be created for an unknown reason' "$L" | cut -d: -f1)
echo "第一条数据存储失败在第 $n 行，前后 25 行："
awk -v s="$n" 'NR>=s-25 && NR<=s+5 {printf "%6d| %s\n", NR, substr($0,1,170)}' "$L"
echo
echo "=== data protection 相关（是否影响 SQLite）==="
grep -ac 'does not support data protection' "$L"
grep -a -m 3 'does not support data protection' "$L" | cut -c1-170

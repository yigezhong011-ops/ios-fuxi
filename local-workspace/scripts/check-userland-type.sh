#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon22/boot.log
echo "=== 用户态里出现的设备/机型字符串 ==="
grep -a -o -i 'iPad[0-9,]*\|iPhone[0-9,]*' "$L" | sort | uniq -c | sort -rn | head -10
echo
echo "=== 系统版本 ==="
grep -a -o -i 'iPadOS [0-9.]*\|iOS [0-9.]*' "$L" | sort | uniq -c | head -5
echo
echo "=== mkiosroot.sh 用法 ==="
sed -n '1,40p' /root/fuxi/mkiosroot.sh

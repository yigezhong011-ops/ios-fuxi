#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon13/boot.log
echo "=== SpringBoard 相关（去重统计）==="
grep -a -o 'SWEET AKS: SpringBoard sel [0-9]*' "$L" | sort | uniq -c | sort -rn | head -10
echo
echo "=== backboardd 相关 ==="
grep -a -o 'SWEET [A-Z]*: backboardd [a-z]* [0-9]*' "$L" | sort | uniq -c | sort -rn | head -10
echo
echo "=== 最后 200 行里的非 ReportCrash ==="
tail -200 "$L" | tr -d '\000' | grep -av 'ReportCrash' | grep -av 'sel 17 arg0 0' | tail -25

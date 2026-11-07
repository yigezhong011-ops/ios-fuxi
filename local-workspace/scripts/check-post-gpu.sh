#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon22/boot.log
echo "=== GPU ready / publish 的具体行 ==="
grep -a -n -E 'FUXI GPU: ready|NativeAdrenoGpuPublished|disabled permanently' "$L" | head -5
echo
echo "=== 最后 30 行（去 NUL）==="
tail -c 3000 "$L" | tr -d '\000' | tail -30
echo
echo "=== AKS / SpringBoard 活动计数 ==="
grep -a -c 'SWEET AKS: SpringBoard' "$L" || true
grep -a -c 'SWEET AKS: backboardd' "$L" || true
echo "=== 崩溃统计 ==="
grep -a -o 'CRASH [A-Za-z0-9._-]*' "$L" | sort | uniq -c | sort -rn | head -6

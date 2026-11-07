#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon23/boot.log
echo "=== SpringBoard 崩溃数 ==="
grep -a -c 'CRASH SpringBoard' "$L" || true
echo "=== 崩溃统计 ==="
grep -a -o 'CRASH [A-Za-z0-9._-]*' "$L" | sort | uniq -c | sort -rn | head -8
echo
echo "=== 帧提交（swap）==="
grep -a -c 'SWEET FB: swap' "$L" || true
echo "=== 显示状态 ==="
grep -a 'SWEET FB: display' "$L" | head -5
echo
echo "=== GPU ==="
grep -a 'FUXI GPU: ready\|NativeAdrenoGpuPublished' "$L" | head -3
echo
echo "=== 资产断言还在吗 ==="
grep -a -c 'BoundingPathBitmap' "$L" || true
echo "=== 最后 15 行 ==="
tail -c 2500 "$L" | tr -d '\000' | tail -15

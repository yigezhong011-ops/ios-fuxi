#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon25/boot.log
echo "=== backboardd matching 次数 ==="
tr -d '\000' < "$L" | grep -a -c 'IOK backboardd: matching1'
echo
echo "=== NativeAdrenoGpuPublished 通知次数 ==="
tr -d '\000' < "$L" | grep -a -o 'NativeAdrenoGpuPublished' | wc -l
echo
echo "=== SWEET FB: backboardd sel 的分布（前 10 种）==="
tr -d '\000' < "$L" | grep -a -o 'SWEET FB: backboardd sel [0-9]*' | sort | uniq -c | sort -rn | head -10
echo
echo "=== 最后 20 行（非重复行）==="
tr -d '\000' < "$L" | grep -av 'matching1' | tail -20

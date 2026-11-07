#!/bin/bash
set -uo pipefail
L=/root/fuxi/s1/boot.log
echo "=== 最后 20 个不同服务（按首次出现）==="
tr -d '\000' < "$L" | grep -a '^exec ' | sed 's/^exec //' | awk '!seen[$0]++' | tail -20
echo
echo "=== 最后 25 行（去噪声）==="
tr -d '\000' < "$L" | grep -av 'SWEET DBG' | grep -av 'SWEET AKS' | grep -av 'matching1' | tail -25
echo
echo "=== 关键字：waiting / blocked / timeout / service ==="
tr -d '\000' < "$L" | grep -a -i 'waiting\|blocked\|timed out\|not ready\|unable' | tail -10

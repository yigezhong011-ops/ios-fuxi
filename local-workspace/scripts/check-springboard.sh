#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon30/boot.log
echo "=== SpringBoard 相关 ==="
tr -d '\000' < "$L" | grep -a -i 'springboard' | tail -12
echo
echo "=== scene / UI 相关 ==="
tr -d '\000' < "$L" | grep -a -i 'scene\|frontboard\|backboardd startup' | tail -8
echo
echo "=== 最后 12 行（去噪）==="
tr -d '\000' < "$L" | grep -av 'SWEET DBG' | grep -av 'matching1' | grep -av 'SWEET AKS' | tail -12

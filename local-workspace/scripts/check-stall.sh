#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon27/boot.log
echo "=== 日志规模 ==="
ls -l "$L" | awk '{print $5" bytes"}'
echo
echo "=== 最后执行的进程（exec）==="
tr -d '\000' < "$L" | grep -a '^exec ' | tail -12
echo
echo "=== 最后的 AKS 调用（前 10 种）==="
tr -d '\000' < "$L" | grep -a 'SWEET AKS:' | tail -8
echo
echo "=== 最后 15 行原始 ==="
tr -d '\000' < "$L" | tail -15

#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon44/boot.log
echo "=== 进度 ==="
tr -d '\000' < "$L" | grep -a -c '^exec ' || true
tr -d '\000' < "$L" | grep -a 'exec SpringBoard\|launchd' | tail -3
echo
echo "=== 根文件系统挂载 / 错误 ==="
tr -d '\000' < "$L" | grep -a -i 'ufsroot\|mount\|extent\|root file\|BSD root' | tail -8
echo
echo "=== 崩溃/panic ==="
tr -d '\000' < "$L" | grep -a -i 'panic\|CRASH\|assert' | tail -6
echo
echo "=== 最后 10 行 ==="
tr -d '\000' < "$L" | tail -10

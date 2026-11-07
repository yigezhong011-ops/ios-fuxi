#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon24/boot.log
echo "=== 日志规模 ==="
ls -l "$L"; grep -a -c 'SWEET DBG' "$L" || true
echo
echo "=== 去掉 DBG 后的最后 25 行 ==="
tr -d '\000' < "$L" | grep -av 'SWEET DBG' | tail -25
echo
echo "=== exec 过的进程（最后 10 个）==="
tr -d '\000' < "$L" | grep -a '^exec ' | tail -10
echo
echo "=== 服务注册 / 崩溃 ==="
tr -d '\000' < "$L" | grep -a 'CRASH' | tail -3

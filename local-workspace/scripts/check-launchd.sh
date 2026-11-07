#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon30/boot.log
echo "=== 最后 25 个不同的 exec 目标 ==="
tr -d '\000' < "$L" | grep -a '^exec ' | tail -25
echo
echo "=== 出现过的服务名（去重，最后 30 个）==="
tr -d '\000' < "$L" | grep -a '^exec ' | sed 's/^exec //' | awk '!seen[$0]++' | tail -30

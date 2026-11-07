#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon34/boot.log
echo "=== SpringBoard 与 framebuffer/GPU 的交互 ==="
tr -d '\000' < "$L" | grep -a 'SWEET FB: SpringBoard\|SWEET SURF: SpringBoard' | head -10
echo
echo "=== SpringBoard 的 AKS/SURF 调用计数 ==="
printf 'FB sel: %s   SURF: %s\n' \
  "$(tr -d '\000' < "$L" | grep -a -c 'SWEET FB: SpringBoard')" \
  "$(tr -d '\000' < "$L" | grep -a -c 'SWEET SURF: SpringBoard')"
echo
echo "=== backboardd 的 surf 活动 ==="
tr -d '\000' < "$L" | grep -a 'SWEET SURF: backboardd' | tail -6
echo
echo "=== 是否有 SpringBoard 的日志行 ==="
tr -d '\000' < "$L" | grep -a '|SpringBoard|' | tail -8

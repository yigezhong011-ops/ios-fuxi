#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon6/boot.log
echo "=== cmdline（确认 fuxigpu=0）==="
grep -a -o 'fuxigpu=[01]' "$L" | head -2
echo
echo "=== SWEET FB 调用 ==="
grep -a -n 'SWEET FB' "$L" | head -15
echo
echo "=== IOAcceleratorES 查询次数 ==="
grep -a -c 'IOAcceleratorES' "$L" || true
echo "=== 前 3 条 ==="
grep -a -n 'IOAcceleratorES' "$L" | head -3
echo
echo "=== 是否有 SpringBoard 之后的 render/surface 活动 ==="
grep -a -niE 'render|composit|swap' "$L" | head -10
echo
echo "=== 行数 ==="; wc -l "$L"

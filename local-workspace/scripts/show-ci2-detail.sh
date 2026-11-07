#!/bin/bash
set -uo pipefail
L=/root/ci2.log
echo "=== 链接错误前 25 行 ==="
sed -n '565,595p' "$L" | cut -c1-200
echo
echo "=== 审计失败附近 ==="
sed -n '615,640p' "$L" | cut -c1-200

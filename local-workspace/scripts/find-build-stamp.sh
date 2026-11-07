#!/bin/bash
set -uo pipefail
O=/root/ux-out/fuxi
echo "=== 步骤标记 / 状态文件 ==="
find "$O" -maxdepth 2 -name '*.json' -o -maxdepth 2 -name '*.stamp' -o -maxdepth 2 -name '.state*' 2>/dev/null | head -10
ls -la "$O" 2>/dev/null | head -12
echo
echo "=== 是否已有 kernel 产物 ==="
ls -lh "$O/kernel/" 2>/dev/null | head -5
find "$O" -name 'link.filelist' 2>/dev/null | head -3
echo
echo "=== bootstrap 日志里的失败点（Error 之前的 5 行）==="
L=$O/logs/kernel-bootstrap.log
line=$(grep -n 'Error 2' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$line" ]; then tail -n +$((line-40)) "$L" | head -45 | tr -d '\000' | sed 's/[^[:print:]]//g' | grep -v '^$' | tail -14; fi

#!/bin/bash
set -uo pipefail
L=/root/ux-out/fuxi/logs/kernel-bootstrap.log
echo "=== 第一条 error ==="
grep -n 'error:' "$L" 2>/dev/null | head -5
echo
echo "=== 上下文 ==="
first=$(grep -n 'error:' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$first" ]; then
  sed -n "$((first-8)),$((first+6))p" "$L" | tr -d '\000' | cut -c1-180
fi
echo
echo "=== 补丁给顶层 Makefile 加的 HOST_CC/HOST_CSH 定义 ==="
grep -n 'HOST_CSH\|HOST_CC' /root/ux-out/fuxi/tree/.cache/xnu-work/Makefile 2>/dev/null | head -10

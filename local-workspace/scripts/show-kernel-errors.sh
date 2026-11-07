#!/bin/bash
set -uo pipefail
L=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/logs/kernel-bootstrap.log
echo "=== 第一批 error: 行 ==="
grep -n 'error:' "$L" 2>/dev/null | head -12
echo
echo "=== 其中一个的上下文 ==="
first=$(grep -n 'error:' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$first" ]; then
  sed -n "$((first-6)),$((first+6))p" "$L"
fi

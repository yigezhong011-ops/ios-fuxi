#!/bin/bash
set -uo pipefail
L=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/logs/kernel-bootstrap.log
echo "=== replacecontents 的编译命令 ==="
grep -n 'replacecontents' "$L" 2>/dev/null | head -6
echo
echo "=== 错误上下文（getprogname 附近）==="
line=$(grep -n 'getprogname' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$line" ]; then sed -n "$((line-25)),$((line+6))p" "$L"; fi

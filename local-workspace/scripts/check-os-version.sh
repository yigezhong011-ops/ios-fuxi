#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon22/boot.log
echo "=== 内核版本 / Darwin ==="
grep -a -o 'Darwin Kernel Version[^,]*' "$L" | head -3
grep -a -o 'xnu-[0-9.]*' "$L" | sort -u | head -3
echo
echo "=== 系统版本字符串 ==="
grep -a -o -E '[0-9]{2}[A-Z][0-9]{3,4}' "$L" | sort | uniq -c | sort -rn | head -5
grep -a -o -E 'iOS [0-9.]+|iPhone OS [0-9.]+|iPadOS [0-9.]+' "$L" | sort | uniq -c | head -5
echo
echo "=== 用户态里的资产名（崩溃那条）==="
grep -a -o 'BoundingPathBitmap-[0-9x.-]*' "$L" | sort -u | head -3
echo
echo "=== launchd/SpringBoard 版本行 ==="
grep -a -i 'SpringBoard.*version\|SystemVersion' "$L" | head -3

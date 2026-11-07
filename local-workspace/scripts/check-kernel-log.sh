#!/bin/bash
set -uo pipefail
L=/root/ux-out/fuxi/logs/kernel.log
echo "=== 行数 ==="
wc -l "$L" 2>/dev/null
echo "=== 错误行 ==="
grep -n 'error:' "$L" 2>/dev/null | head -6
grep -n 'unsupported option' "$L" 2>/dev/null | head -4
grep -n 'Error ' "$L" 2>/dev/null | head -4
echo "=== 尾部 ==="
tail -8 "$L" 2>/dev/null | cut -c1-160
echo
echo "=== 所有日志文件 ==="
ls -lh --time-style=+%H:%M /root/ux-out/fuxi/logs/ 2>/dev/null | tail -6

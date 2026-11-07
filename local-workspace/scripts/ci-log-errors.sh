#!/bin/bash
set -uo pipefail
L=/root/ci-job.log
echo "=== 日志里的 error: ==="
grep -n 'error:' "$L" 2>/dev/null | head -10 | cut -c1-220
echo
echo "=== Error 2 / failed 之前 10 行 ==="
line=$(grep -n 'Error 2' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$line" ]; then sed -n "$((line-12)),$((line+2))p" "$L" | cut -c1-200; fi
echo
echo "=== Build 步骤开头 ==="
grep -n 'kernel: ' "$L" | head -6

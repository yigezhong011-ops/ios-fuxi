#!/bin/bash
set -uo pipefail
L=/root/kernel-ext4.log
echo "=== error: 行（前 12 条）==="
grep -n 'error:' "$L" 2>/dev/null | head -12
echo
echo "=== 第一条的上下文 ==="
first=$(grep -n 'error:' "$L" 2>/dev/null | head -1 | cut -d: -f1)
if [ -n "$first" ]; then sed -n "$((first-4)),$((first+6))p" "$L"; fi
echo
echo "=== fatal / undefined / ld: 行 ==="
grep -nE 'fatal|undefined|ld: ' "$L" 2>/dev/null | head -10

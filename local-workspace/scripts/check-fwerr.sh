#!/bin/bash
set -uo pipefail
L=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi/logs/firmware.log
echo "=== 错误上下文 ==="
grep -n -i -B3 -A8 'error 7000\|error 4000\|GenFv\|duplicate\|not found\|Error' "$L" | tail -60

#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/tools/stage-fuxi-metal.py
echo "=== translator / icd 处理 ==="
grep -n -B3 -A12 'translator' "$F" | head -50

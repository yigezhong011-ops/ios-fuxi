#!/bin/bash
set -uo pipefail
F=/root/fuxi/uni-fork/scripts/make-gpu-addon.py
echo "=== 用法 ==="
grep -n 'add_argument\|usage' "$F" | head -14 | cut -c1-150
echo
echo "=== 前 25 行 ==="
head -25 "$F" | cut -c1-140

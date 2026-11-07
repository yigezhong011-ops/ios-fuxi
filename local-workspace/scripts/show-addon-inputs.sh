#!/bin/bash
set -uo pipefail
F=/root/fuxi/uni-fork/scripts/make-gpu-addon.py
echo "=== 参数与输入路径 ==="
grep -n 'sys.argv\|def main\|ROOT\|bundle\|addons/\|Path(' "$F" | head -25 | cut -c1-160
echo
echo "=== 末尾 40 行 ==="
tail -40 "$F" | cut -c1-150

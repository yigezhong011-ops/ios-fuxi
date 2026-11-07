#!/bin/bash
set -uo pipefail
F=/root/fuxi/fork-device/scripts/build-boot-progress.py
echo "=== 行数 $(wc -l < "$F") ==="
grep -n 'define' "$F" | head -14 | cut -c1-170
echo
echo "=== 前 30 行 ==="
sed -n '1,30p' "$F" | cut -c1-160

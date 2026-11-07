#!/bin/bash
set -uo pipefail
L=/root/hackios/xnuloader/loader.c
echo "=== platform 选择 / fb_base 匹配 ==="
grep -n -B4 -A12 'fb_base' "$L" | head -60
echo
echo "=== 未匹配时的行为 ==="
grep -n -A8 'platforms\[\]' "$L" | head -30

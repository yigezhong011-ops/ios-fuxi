#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== 树里的 Font.h ==="
find "$T" -name 'Font.h' 2>/dev/null | head -5
echo
echo "=== 谁生成 Font.h ==="
grep -rln 'Font.h' "$T/scripts" 2>/dev/null | head -5
grep -rn "font_dir\s*=" "$T/scripts/patch-xnu-entry-probe.py" 2>/dev/null | head -4 | cut -c1-170
echo
echo "=== 生成字体脚本 ==="
ls "$T/scripts" | grep -i 'font' | head -5

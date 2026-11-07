#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== 顶层文档 ==="
ls -1 *.md 2>/dev/null
echo
echo "=== docs-lanes ==="
ls -1 docs-lanes/*.md 2>/dev/null | head -40
echo
echo "=== 是否存在 NOTES.md ==="
find . -maxdepth 2 -iname 'NOTES*.md' 2>/dev/null
echo
echo "=== 提到 SpringBoard / boot progress / 首次启动 的文档 ==="
grep -rln -i 'springboard\|boot progress\|first boot\|setupdone' --include='*.md' . 2>/dev/null | head -12

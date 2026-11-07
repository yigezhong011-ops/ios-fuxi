#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
echo "=== uefi-fuxi 大小 ==="
du -sh "$U" 2>/dev/null
echo
echo "=== 构建依赖 ==="
cat "$U/pip-requirements.txt" 2>/dev/null | head -10
echo
echo "=== Building.md 的 Linux 部分 ==="
grep -n -i -A8 'linux' "$U/Building.md" 2>/dev/null | head -25 | cut -c1-140
echo
echo "=== WSL 已有工具 ==="
for t in nasm iasl python3 pip3 gcc; do printf '%-8s ' "$t"; command -v $t >/dev/null && echo OK || echo 缺; done

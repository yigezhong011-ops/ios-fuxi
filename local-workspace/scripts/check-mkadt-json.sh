#!/bin/bash
set -uo pipefail
echo "=== step24 里的 ADT 生成 ==="
grep -n 'mkadt\|EXT=\|--root' /mnt/e/DSH-Fuxi/dump/wsl/step24-build-diag2.sh | head -12
echo
echo "=== mkadt-fuxi.py 读取 JSON 的字段 ==="
grep -n "size\|bytes\|extents" /root/ios-fuxi/tools/mkadt-fuxi.py | head -12

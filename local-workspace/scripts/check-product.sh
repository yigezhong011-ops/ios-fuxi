#!/bin/bash
set -uo pipefail
echo "=== mkadt.py 里的 /product 处理 ==="
grep -n -B4 -A18 'product' /root/ios-fuxi/tools/mkadt.py | head -45
echo
echo "=== d22ap.adt 是什么（research 目录）==="
ls -l /root/ios-fuxi/research/ 2>/dev/null | head -8

#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== package 里与 GPU 相关的源文件 ==="
ls "$D/package" | grep -i 'gpu' | head -10
echo
echo "=== 哪里定义 setPageTable 调用 ==="
grep -rln 'setPageTable' "$D/package" "$D" 2>/dev/null | head -5

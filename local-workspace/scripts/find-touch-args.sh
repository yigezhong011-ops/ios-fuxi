#!/bin/bash
set -uo pipefail
D=/root/fuxi/uni-fork/docs
ls "$D" | head -20
echo "=== 找参数目录文件 ==="
find "$D" -name '*boot-arg*' -o -name '*arguments*' | head -5
echo "=== 全文档搜 touch 启动参数 ==="
grep -rn 'touchscreen=\|touch=\|sheng-touch\|sheng-input' "$D" 2>/dev/null | head -12 | cut -c1-160

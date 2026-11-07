#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== 报错文本位置 ==="
grep -rn 'Boot progress requires' scripts/ | head -5
echo
echo "=== 上下文 ==="
L=$(grep -rn 'Boot progress requires' scripts/ | head -1 | cut -d: -f2)
F=$(grep -rln 'Boot progress requires' scripts/ | head -1)
echo "file: $F line: $L"
sed -n "$((L-30)),$((L+15))p" "$F"

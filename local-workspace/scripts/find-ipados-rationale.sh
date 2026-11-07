#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build
echo "=== unixnu 文档里提到 iPad7,1 / iPadOS 的地方 ==="
grep -rn -iE 'iPad7,1|iPadOS 17|ipados-17' "$B/unixnu/docs" 2>/dev/null | head -10
echo
echo "=== 为什么选这个平台（找 rationale）==="
grep -rn -iE 'iPad7,1.*(because|chosen|reference|why)|reference platform|参考平台' "$B/unixnu/docs" "$B/fuxi" 2>/dev/null | head -8
echo
echo "=== os profile 列表 ==="
find "$B/unixnu" -name '*ipados*' -o -name '*17.7*' 2>/dev/null | head -10

#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== 内核里与 metadata / client text 相关的实现 ==="
grep -rn 'Metadata\|client text\|process text\|SHENGTHROW' "$D" 2>/dev/null | head -12
echo
echo "=== 内核里的 FUXI MTL / gpu 打印点 ==="
grep -rn 'printf("FUXI' "$D" 2>/dev/null | head -12

#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== 内核是否把客户端文本打到控制台 ==="
grep -rn 'metadata' "$D"/*.cpp "$D"/*.inc "$D"/*.c 2>/dev/null | head -15
echo
echo "=== 是否有 gpu client text 之类 ==="
grep -rn 'client_text\|client text\|gpu client' "$D" 2>/dev/null | head -8
echo
echo "=== scanout 相关文件 ==="
ls -l "$D" | head -20

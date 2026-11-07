#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi/xnu
echo "=== sweetsample / sweetscan 定义处 ==="
grep -rn 'sweetsample' . --include='*.c' --include='*.cpp' --include='*.h' | head -6
grep -rn 'sweetscan' . --include='*.c' --include='*.cpp' --include='*.h' | head -6
echo
echo "=== 它们的输出形式 ==="
F=$(grep -rln 'sweetsample' . --include='*.c' --include='*.cpp' | head -1)
echo "file: $F"
grep -n -A6 -B2 'sweetsample' "$F" | head -40

#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/tools/mesa-ios/userland
echo "=== 桥的源文件 ==="
ls -l "$D" 2>/dev/null | head -8
echo
echo "=== eagl.c 里的日志/失败路径 ==="
grep -n 'fprintf\|printf\|stderr\|FUXI\|fail\|NULL;' "$D/eagl.c" 2>/dev/null | head -30
echo
echo "=== gl_osmesa.c 的失败路径 ==="
grep -n 'fprintf\|printf\|stderr\|fail' "$D/gl_osmesa.c" 2>/dev/null | head -20

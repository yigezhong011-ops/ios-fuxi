#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/mesa-ios/userland
echo "=== eagl.c includes ==="
grep -n '#include' "$D/eagl.c" | head -20
echo
echo "=== gl_osmesa.c includes ==="
grep -n '#include' "$D/gl_osmesa.c"
echo
echo "=== eagl.c 前 40 行 ==="
sed -n '1,40p' "$D/eagl.c"

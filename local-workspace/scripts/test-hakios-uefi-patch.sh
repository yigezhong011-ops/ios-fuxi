#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
P=/root/hakios-uefi/hakios.patch
echo "=== 补丁大小 ==="
wc -l "$P" 2>/dev/null
echo
echo "=== 能否应用到我们的 uefi-fuxi ==="
git -C "$U" apply --check --whitespace=nowarn "$P" 2>&1 | head -12
echo "apply --check 退出码: $?"
echo
echo "=== 补丁改了哪些文件 ==="
grep '^diff --git' "$P" 2>/dev/null | head -12 | cut -c1-120

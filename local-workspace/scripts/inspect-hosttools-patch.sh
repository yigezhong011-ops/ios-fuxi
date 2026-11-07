#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/patches/xnu
echo "=== linux-host-tools.patch 改了哪些文件 ==="
grep -E '^(\+\+\+|---) ' "$P/linux-host-tools.patch" | head -20
echo
echo "=== 补丁行数 ==="
wc -l "$P"/*.patch
echo
echo "=== 构建树里是否已包含补丁内容 ==="
T=/root/ux-out/fuxi/tree/.cache/xnu-work/makedefs
grep -n 'HOST_CC\|host-clang\|linux' "$T/MakeInc.cmd" 2>/dev/null | head -8

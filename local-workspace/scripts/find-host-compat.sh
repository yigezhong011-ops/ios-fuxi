#!/bin/bash
set -uo pipefail
T=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
echo "=== HOST_COMPAT_CFLAGS / LIBS 定义在哪 ==="
grep -rn 'HOST_COMPAT' "$T"/env.sh "$T"/patches/xnu/*.patch 2>/dev/null | head -10
echo
echo "=== 构建树里是否有定义 ==="
grep -rn 'HOST_COMPAT' /root/ux-out/fuxi/tree/.cache/xnu-work/makedefs/*.cmd 2>/dev/null | head -6
grep -rn 'HOST_COMPAT' /root/ux-out/fuxi/tree/.cache/xnu-work/Makefile 2>/dev/null | head -4

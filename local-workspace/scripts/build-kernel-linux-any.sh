#!/bin/bash
# Build the fuxi kernel with Allenwdk's Linux toolchain (host-clang for SETUP,
# target-clang for the kernel, cctools ld64 for the link).
set -uo pipefail
PREFIX=$HOME/.local/xnu-linux
[ -f "$PREFIX/env.sh" ] || { echo "缺少 $PREFIX/env.sh"; exit 1; }
# shellcheck disable=SC1091
source "$PREFIX/env.sh"

echo "=== 工具链 ==="
echo "  host-clang:   $(command -v host-clang)"
echo "  target-clang: $(command -v target-clang)"
echo "  ld:           $(command -v ld)"
echo "  CCC_OVERRIDE_OPTIONS=${CCC_OVERRIDE_OPTIONS:-<未设置>}"

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu
LOG=/root/kernel-build.log
: > "$LOG"
./unixnu build kernel -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo
echo "KERNEL_EXIT=$code"
echo "=== 日志尾部 ==="
tail -30 "$LOG"

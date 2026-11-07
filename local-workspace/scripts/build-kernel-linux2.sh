#!/bin/bash
# Build the fuxi kernel with the Linux toolchain (sourced from the repo, as its
# env.sh documents).
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
PREFIX=$HOME/.local/xnu-linux

echo "=== 工具链状态 ==="
ls "$PREFIX/cctools" 2>/dev/null | head -6 || echo "  cctools 目录不存在"
[ -x "$PREFIX/bin/migcom" ] && echo "  migcom ✓"
# shellcheck disable=SC1091
source "$REPO/env.sh" || { echo "env.sh 失败"; exit 1; }

echo "=== 解析结果 ==="
for t in host-clang target-clang ld migcom iig plutil xcrun; do
  printf '  %-12s %s\n' "$t" "$(command -v $t 2>/dev/null || echo '缺失')"
done
echo "  CCC_OVERRIDE_OPTIONS=${CCC_OVERRIDE_OPTIONS:-<空>}"

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu
LOG=/root/kernel-build.log
: > "$LOG"
./unixnu build kernel -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
echo
echo "KERNEL_EXIT=$?"
echo "=== 日志尾部 ==="
tail -30 "$LOG"

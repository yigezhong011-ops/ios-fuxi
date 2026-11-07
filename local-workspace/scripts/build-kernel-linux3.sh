#!/bin/bash
# Build the fuxi kernel on Linux. XNU's SETUP tools are macOS code compiled with
# upstream clang, so a few diagnostics escalate under -Werror; the toolchain
# documents CCC_OVERRIDE_OPTIONS for exactly that (downgrade one diagnostic at a
# time, never a global -Wno-error).
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
PREFIX=$HOME/.local/xnu-linux
# shellcheck disable=SC1091
source "$REPO/env.sh" || exit 1

export CCC_OVERRIDE_OPTIONS="+-D_GNU_SOURCE \
+-Wno-error=format \
+-Wno-error=implicit-function-declaration \
+-Wno-error=incompatible-pointer-types \
+-Wno-error=int-conversion \
+-Wno-error=unused-but-set-global"

echo "=== CCC_OVERRIDE_OPTIONS ==="
echo "$CCC_OVERRIDE_OPTIONS" | sed 's/^/  /'

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu
LOG=/root/kernel-build.log
: > "$LOG"
./unixnu build kernel -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo
echo "KERNEL_EXIT=$code"
echo "=== 日志尾部 ==="
tail -20 "$LOG"

#!/bin/bash
# Run the xnu baseline script directly so the failing command and its error are
# both in the log (the driver's wrapper hides them behind the pipe).
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
# shellcheck disable=SC1091
source "$REPO/env.sh" || exit 1
export UNIXNU_SDKROOT=/root/ux-out/fuxi/tree/.cache/fakeroot
export UNIXNU_SDK_VERSION=17.0
export UNIXNU_PLATFORM_PATH=$UNIXNU_SDKROOT/Platforms/iPhoneOS.platform
export CROSS_CLANG=/opt/unixnu-linux/llvm/bin/clang
export DARWIN_TRIPLE=arm64-apple-ios17.0
export CROSS_EXTRA_FLAGS='-mllvm -disable-atexit-based-global-dtor-lowering'
export HOST_CC=/opt/unixnu-linux/CommandLineTools/usr/bin/xnu-host-cc
export CCC_OVERRIDE_OPTIONS='# +-Wno-missing-designated-field-initializers +-Wno-unused-but-set-global +-Wno-error=format +-Wno-error=implicit-function-declaration'

cd /root/ux-out/fuxi/tree || exit 1
LOG=/root/xnu-direct.log
: > "$LOG"
bash scripts/build-xnu-4k-baseline.sh >>"$LOG" 2>&1
echo "DIRECT_EXIT=$?"
echo "=== 日志行数 ==="
wc -l "$LOG"
echo "=== 失败标记 ==="
grep -n '\*\*\*' "$LOG" | head -10
echo "=== 错误 ==="
grep -nE 'error:|undefined symbol|ld: |cannot' "$LOG" | head -10
echo "=== 尾部 ==="
tail -12 "$LOG"

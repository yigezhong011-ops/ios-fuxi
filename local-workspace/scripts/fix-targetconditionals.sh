#!/bin/bash
# The firehose step needs TargetConditionals.h, which the Linux toolchain ships.
# Put it where xnu-host-cc searches (-idirafter .../MacOSX.sdk/usr/include).
set -euo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
PREFIX=$HOME/.local/xnu-linux
SDK=/opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include

echo "=== 找 TargetConditionals.h ==="
for f in "$REPO/toolchain/TargetConditionals.h" "$PREFIX/include/TargetConditionals.h"; do
  if [ -f "$f" ]; then echo "  找到: $f"; SRC=$f; fi
done
[ -n "${SRC:-}" ] || { echo "  仓库里没有，从系统 clang 资源目录找"; SRC=$(find /usr/lib/llvm-*/lib/clang/*/include -name TargetConditionals.h 2>/dev/null | head -1); echo "  $SRC"; }

if [ -n "${SRC:-}" ] && [ -f "$SRC" ]; then
  for d in "$SDK" "$PREFIX/include" /opt/unixnu-linux/CommandLineTools/usr/include; do
    mkdir -p "$d"
    cp -f "$SRC" "$d/TargetConditionals.h"
    echo "  已复制到 $d"
  done
else
  echo "  没找到 TargetConditionals.h"
  exit 1
fi

echo
echo "=== Allenwdk 的 firehose 脚本 ==="
ls -l "$REPO/scripts/" | head -8

#!/bin/bash
# The firehose compile searches the fakeroot include directories, so put
# TargetConditionals.h there (kern/debug.h includes it unconditionally).
set -euo pipefail
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h
ROOT=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree
[ -f "$SRC" ] || { echo "源文件不存在"; exit 1; }
for d in \
  "$ROOT/.cache/fakeroot/usr/include" \
  "$ROOT/.cache/fakeroot/usr/local/include" \
  "$ROOT/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/Headers" \
  "$ROOT/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/PrivateHeaders" ; do
  mkdir -p "$d"
  cp -f "$SRC" "$d/TargetConditionals.h"
  echo "已复制 -> $d"
done
ls -l "$ROOT/.cache/fakeroot/usr/include/TargetConditionals.h"

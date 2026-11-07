#!/bin/bash
# Copy the Linux build's TargetConditionals.h into every include directory the
# kernel build searches, so kern/debug.h and friends can find it.
set -euo pipefail
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h
[ -f "$SRC" ] || { echo "源文件不存在: $SRC"; exit 1; }
for d in \
  /opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include \
  /opt/unixnu-linux/CommandLineTools/usr/include \
  /root/.local/xnu-linux/include ; do
  mkdir -p "$d"
  cp -f "$SRC" "$d/TargetConditionals.h"
  echo "已复制 -> $d/TargetConditionals.h"
done
ls -l /opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include/TargetConditionals.h

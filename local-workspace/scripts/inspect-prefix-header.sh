#!/bin/bash
set -uo pipefail
P=/opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include/unixnu-host-prefix.h
echo "=== unixnu-host-prefix.h 前 30 行 ==="
sed -n '1,30p' "$P" 2>/dev/null
echo
echo "=== 补丁给 SETUP/config/Makefile 的改动 ==="
awk '/^--- a\/SETUP\/config\/Makefile/,/^--- a\/SETUP\/decomment/' \
  /mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/patches/xnu/linux-host-tools.patch | head -25

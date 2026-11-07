#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/patches/xnu/linux-host-tools.patch
T=/root/ux-out/fuxi/tree/.cache/xnu-work
echo "=== 补丁里 bsd/conf/Makefile 的改动 ==="
awk '/^--- a\/bsd\/conf\/Makefile/,/^--- a\/iokit/' "$P" | head -30
echo
echo "=== 树里的 bsd/conf/Makefile 是否含补丁特征 ==="
grep -nE 'HOST_CC|host|linux|x86_64' "$T/bsd/conf/Makefile" 2>/dev/null | head -8
echo
echo "=== 树里的顶层 Makefile（前 20 行）==="
head -20 "$T/Makefile" 2>/dev/null

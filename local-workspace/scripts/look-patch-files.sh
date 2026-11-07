#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== 补丁里新增的 include / 依赖 ==="
grep -n -E '^\+#include|XnuLoader|PAYLOAD_BASE|PayloadBase' uefi/mu-silicium.patch | head -20
echo
echo "=== uefi/files 下的 BootManagerLib 新文件 ==="
find uefi/files -type f | head -20
echo
echo "=== BootShim 的改动 ==="
awk '/BootShim\/BootShim.S/,/BootManager.c/' uefi/mu-silicium.patch | head -60

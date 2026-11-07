#!/bin/bash
set -uo pipefail
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
echo "=== 设备仓库的 [uefi] 段 ==="
awk '/^\[uefi\]/,/^\[/ {print}' "$DEV/board.toml" 2>/dev/null | head -14 | cut -c1-140
echo
echo "=== [uefi_fd] 段 ==="
awk '/^\[uefi_fd\]/,/^\[/ {print}' "$DEV/board.toml" 2>/dev/null | head -10 | cut -c1-140
echo
echo "=== firmware 子命令帮助 ==="
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu && ./unixnu build --help 2>&1 | grep -A2 firmware | head -8
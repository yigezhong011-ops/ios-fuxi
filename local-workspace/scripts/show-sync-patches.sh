#!/bin/bash
set -uo pipefail
T=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
echo "=== sync-patches.sh 全文（前 40 行）==="
sed -n '1,40p' "$T/scripts/sync-patches.sh"
echo
echo "=== UniXNU 现有 xnu 补丁数 ==="
ls /mnt/e/DSH-Fuxi/unixnu-build/unixnu/patches/xnu/ 2>/dev/null | wc -l
ls /mnt/e/DSH-Fuxi/unixnu-build/unixnu/patches/xnu/ 2>/dev/null | head -5

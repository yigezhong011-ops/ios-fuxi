#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== prebuilt/userland ==="
ls -la prebuilt/userland 2>/dev/null | head -10
echo
echo "=== build.sh 前 25 行 ==="
head -25 userland/build.sh | cut -c1-140
echo
echo "=== 依赖工具 ==="
grep -oE '\b(hdiutil|newfs_apfs|mkfs\.apfs|clang|ld64|xcrun|python3)\b' userland/build.sh 2>/dev/null | sort -u

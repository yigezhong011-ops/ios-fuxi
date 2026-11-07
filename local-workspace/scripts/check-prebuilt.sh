#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== prebuilt ==="
ls -la prebuilt 2>/dev/null | head -12
echo
echo "=== sysimage 内容（解包结果）==="
ls sysimage 2>/dev/null
echo
echo "=== userland 目录 ==="
ls userland 2>/dev/null | head -12
echo
echo "=== userland/build.sh 是否需要 macOS ==="
grep -n 'uname\|Darwin\|hdiutil\|newfs_apfs' userland/build.sh 2>/dev/null | head -8 | cut -c1-140

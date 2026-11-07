#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build
echo "=== bootimage.py 是否需要 xcrun/hdiutil ==="
grep -n 'xcrun\|hdiutil\|darwin\|macOS\|platform.system' "$B/uefi-fuxi/scripts/bootimage.py" 2>/dev/null | head -10
echo
echo "=== build-adreno-metal-plugin.py 需要什么 ==="
grep -n 'xcrun\|hdiutil\|sdk\|clang\|codesign' "$B/unixnu/scripts/build-adreno-metal-plugin.py" 2>/dev/null | head -10
echo
echo "=== Linux 工具链脚本 ==="
ls "$B/unixnu/scripts/linux/" 2>/dev/null | head -10
head -20 "$B/unixnu/scripts/linux/setup-toolchain.py" 2>/dev/null

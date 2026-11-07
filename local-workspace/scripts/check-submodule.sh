#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/DeviceBuild.py
echo "=== 子模块相关代码 ==="
grep -n -i 'submodule' "$P" | head -10 | cut -c1-150
echo
echo "=== Binaries 目录状态 ==="
ls -d /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/.git 2>/dev/null && echo '有 .git' || echo '没有 .git（所以它想重新 clone）'
du -sh /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries 2>/dev/null
ls /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/ 2>/dev/null | head -5

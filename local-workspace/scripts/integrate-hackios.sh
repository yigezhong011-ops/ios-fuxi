#!/bin/bash
set -euo pipefail
cd /root/hackios
MU=/root/uefi-fuxi

echo "=== 1. 复制 XnuLoader 新文件 ==="
cp uefi/files/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.[ch] \
   "$MU/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/"
ls -l "$MU/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/" | grep -i xnu

echo "=== 2. 应用 hackios 的 UEFI 补丁 ==="
cd "$MU"
git apply --check /root/hackios/uefi/mu-silicium.patch && git apply /root/hackios/uefi/mu-silicium.patch && echo "PATCH_APPLIED"
grep -n 'XnuLoaderMain' Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/BootManager.c | head -3

echo "=== 3. 资源目录检查 ==="
ls Resources/Scripts/mkbootimg.py Resources/DTBs 2>&1 | head -5

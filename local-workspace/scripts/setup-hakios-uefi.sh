#!/bin/bash
# Bring HakiOS's UEFI core next to our fuxi Mu-Silicium platform.
set -uo pipefail
cd /root
if [ ! -d /root/hakios-uefi/.git ]; then
  git clone -q --depth 1 https://github.com/oosexgang/hakios-uefi.git /root/hakios-uefi && echo "已克隆 hakios-uefi"
fi
echo "=== 核心 apply.sh ==="
head -40 /root/hakios-uefi/apply.sh 2>/dev/null
echo
echo "=== 我们的 fuxi 平台 ==="
ls /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/ 2>/dev/null
ls /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/ 2>/dev/null | head -10

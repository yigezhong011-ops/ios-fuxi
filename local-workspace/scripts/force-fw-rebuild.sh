#!/bin/bash
set -uo pipefail
echo "=== 上次固件构建日志尾部 ==="
tail -15 /root/fw7.log 2>/dev/null || true
echo
echo "=== 强制重建 ==="
touch /root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw-xnu2.log 2>&1
echo "FW_EXIT=$?"
grep -iE 'error|XnuLoader' /root/fw-xnu2.log | head -8
ls -l --time-style=+%H:%M /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd

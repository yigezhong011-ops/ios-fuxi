#!/bin/bash
set -uo pipefail
L=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi/logs/firmware.log
echo "=== 构建日志里 FuxiRamDiskDxe 相关 ==="
grep -n -i 'FuxiRamDiskDxe' "$L" | head -10
echo
echo "=== 生成的 .efi ==="
find /root/uefi-fuxi/Build/fuxiPkg -iname 'FuxiRamDiskDxe*' 2>/dev/null | head -5
echo
echo "=== FV 内容列表（GenFv 的 FVMAIN.inf）==="
grep -n 'EFI_FILE_NAME' /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/FVMAIN.inf 2>/dev/null | head -30

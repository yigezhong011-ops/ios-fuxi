#!/bin/bash
set -uo pipefail
DSC=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc
INC=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc
FDF=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.fdf

echo "=== DSC 的 LibraryClasses 开头 ==="
grep -n -A5 '\[LibraryClasses\]' "$DSC" | head -12
echo
echo "=== DSC 里是否已有 FdtLib/HobLib（任意形式）==="
grep -n -i 'fdtlib\|hoblib' "$DSC" | head -5 || echo "(无)"
echo
echo "=== DXE.inc 里 FuxiRamDiskDxe 那行 ==="
grep -n -i 'FuxiRamDiskDxe\|FatPkg\|DiskIoDxe' "$INC" | head -6
echo
echo "=== DSC [Components] 里 UniXNU 相关 ==="
grep -n 'UniXNUPkg' "$DSC" | head -8

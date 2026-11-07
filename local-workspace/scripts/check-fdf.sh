#!/bin/bash
set -uo pipefail
FDF=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.fdf
FD=/root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
echo "=== FDF 中的 ramdisk/diskio/fat ==="
grep -n -i 'ramdisk' "$FDF" || echo "(FDF 中没有 FuxiRamDiskDxe!)"
grep -n -i 'Fat.inf\|DiskIo' "$FDF" || echo "(FDF 中没有 Fat/DiskIo)"
echo
echo "=== FDF 中的 INF 列表（前 40 行）==="
grep -n 'INF ' "$FDF" | head -40
echo
echo "=== 固件卷里搜驱动字符串 ==="
strings "$FD" | grep -i 'FUXIRAMDISK' | head -3 || echo "(没有 FUXIRAMDISK 字符串 -> 驱动未编入)"
strings "$FD" | grep -i 'UniXNU' | head -3 || echo "(没有 UniXNU 字符串)"

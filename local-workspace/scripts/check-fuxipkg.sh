#!/bin/bash
set -uo pipefail
P=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg
echo "=== fuxiPkg 目录 ==="
ls "$P"
echo
echo "=== DSC 里的 UniXNU / RamDisk / DiskIo / FAT 模块 ==="
grep -n -i -E 'unixnu|ramdisk|diskiodevice|diskio|fat|darwinboot' "$P/fuxi.dsc" 2>/dev/null | head -30 || echo "(DSC 中未匹配)"
echo
echo "=== FDF 里的相关模块 ==="
ls "$P"/*.fdf 2>/dev/null
grep -rn -i -E 'unixnu|ramdisk|darwinboot' "$P"/*.fdf 2>/dev/null | head -20 || echo "(FDF 中未匹配)"

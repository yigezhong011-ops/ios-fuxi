#!/bin/bash
set -uo pipefail
D=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe
echo "=== 目录 ==="
ls "$D"
echo
echo "=== 关键常量与解析逻辑 ==="
grep -rn -E '#define|ANDROID|magic|Magic|0x[0-9A-Fa-f]{6,}|ramdisk|Ramdisk|RAMDISK' "$D"/*.c "$D"/*.h 2>/dev/null | head -40

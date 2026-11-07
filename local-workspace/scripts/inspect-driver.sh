#!/bin/bash
set -uo pipefail
F=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
ls -l "$F"
echo "=== 含 SIGNAL 的行 ==="
grep -n 'SIGNAL' "$F" | head -10
echo "=== 含 mVolumeBase == NULL 的行 ==="
grep -n 'mVolumeBase == NULL' "$F"
echo "=== 300-315 行原样 ==="
sed -n '300,315p' "$F"

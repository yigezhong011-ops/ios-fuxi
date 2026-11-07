#!/bin/bash
# Does the working kernel carry a fuxi touch driver?
set -uo pipefail
W=/root/fuxi/userboot
mkdir -p "$W/mnt4"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,ro "$W/payload.img" "$W/mnt4"
K="$W/mnt4/EFI/UniXNU/Payloads/kernel.macho"
echo "内核 $K"
cp "$K" /tmp/working-kernel.macho 2>/dev/null
umount "$W/mnt4"

echo "=== 触控相关字符串 ==="
strings -n 6 /tmp/working-kernel.macho 2>/dev/null | grep -i 'fts\|focal\|novatek\|goodix\|touch' | sort -u | head -25
echo
echo "=== 电池/背光相关 ==="
strings -n 6 /tmp/working-kernel.macho 2>/dev/null | grep -i 'battery\|fuel\|backlight\|brightness' | sort -u | head -15

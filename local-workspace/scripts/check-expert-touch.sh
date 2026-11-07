#!/bin/bash
set -uo pipefail
K=/root/insp-user/body.bin
echo "=== 从 payload 取内核 ==="
mkdir -p /root/insp-user/mnt
mount -t vfat -o loop,ro /root/insp-user/payload.img /root/insp-user/mnt 2>/dev/null
cp /root/insp-user/mnt/EFI/UniXNU/Payloads/kernel.macho /root/insp-user/kernel.macho 2>/dev/null
umount /root/insp-user/mnt 2>/dev/null
ls -l /root/insp-user/kernel.macho
echo
echo "=== 触控相关的字符串 ==="
strings -a /root/insp-user/kernel.macho 2>/dev/null | grep -i 'sheng-touch\|goodix\|gt9916\|focaltech\|fts\|touch-hid' | sort -u | head -20 | cut -c1-120

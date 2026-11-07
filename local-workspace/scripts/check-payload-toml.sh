#!/bin/bash
set -uo pipefail
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mkdir -p /root/fuxi/pl2
mount -t vfat -o loop,ro /root/fuxi/pkg2/payload.img /root/fuxi/pl2
echo "=== payload 里的文件 ==="
find /root/fuxi/pl2 -type f -printf '  %-56p %10s B\n'
echo "=== toml ==="
cat /root/fuxi/pl2/EFI/UniXNU/unixnu.toml
umount /root/fuxi/pl2

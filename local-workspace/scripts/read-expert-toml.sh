#!/bin/bash
# Read the expert payload's original args (the image we never modified).
set -uo pipefail
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
M=/root/fuxi/ple
mkdir -p "$M"
mount -t vfat -o loop,ro /root/fuxi/expert-payload-vol.img "$M"
echo "=== 专家版原始 unixnu.toml ==="
cat "$M/EFI/UniXNU/unixnu.toml"
umount "$M"

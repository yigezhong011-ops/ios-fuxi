#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img
M=/root/fuxi/mnt/payload
mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,ro,utf8 "$IMG" "$M" 2>/dev/null || mount -t vfat -o loop,ro "$IMG" "$M"
echo "=== 负载卷内容 ==="
ls -lR "$M" 2>/dev/null | head -30
echo
echo "=== unixnu.toml（如果有）==="
find "$M" -name '*.toml' -exec cat {} \; 2>/dev/null | head -40
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

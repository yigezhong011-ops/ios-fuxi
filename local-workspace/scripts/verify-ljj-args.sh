#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img
M=/root/fuxi/mnt/payload3
mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,ro "$IMG" "$M"
echo "=== 关键参数是否都在 ==="
for k in sheng-gpu-metal=1 sheng-fb-gpu=1 sheng-vsync=120 sheng-gpu-addon=1 sheng-gpu-dcvs=1 \
         native-fuxi-ufs-root=1 sheng-data-persist=2 sheng-lite=1 sheng-log=1 boot-progress=2; do
  if grep -q "$k" "$M/EFI/UniXNU/unixnu.toml"; then echo "  ✓ $k"; else echo "  ✗ $k"; fi
done
echo
echo "=== 参数总长度 ==="
grep -o 'args = "[^"]*"' "$M/EFI/UniXNU/unixnu.toml" | head -1 | wc -c
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

#!/bin/bash
# Read the GPU16 payload volume: its menu config (kernel args), and what files it
# carries compared with the expert payload.
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/payload-gpu16.img
M=/root/fuxi/mnt/gpu16
mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,ro "$IMG" "$M"
echo "=== GPU16 payload 内容 ==="
find "$M" -type f -printf '  %-52p %10s B\n' | sort
echo
echo "=== unixnu.toml ==="
TOML=$(find "$M" -iname 'unixnu.toml' | head -1)
[ -n "$TOML" ] && cat "$TOML"
echo
echo "=== 与专家 payload 的文件名差异 ==="
EXP=/root/fuxi/expert-payload
ls "$M/EFI/UniXNU/Payloads" 2>/dev/null || find "$M" -type d | head
umount "$M"

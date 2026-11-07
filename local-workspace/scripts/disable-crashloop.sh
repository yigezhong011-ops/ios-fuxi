#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/disable
mkdir -p "$M"
mount -t hfsplus -o loop,rw,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }

disable() {
  local name=$1
  local f
  for f in "$M/System/Library/LaunchDaemons/$name"*.plist; do
    [ -e "$f" ] || continue
    mv "$f" "$f.disabled"
    echo "disabled: $(basename "$f")"
  done
}

disable com.apple.bluetoothd
disable com.apple.fairplayd
disable com.apple.driverkitd

echo "=== 确认 ==="
ls "$M/System/Library/LaunchDaemons" | grep -E 'bluetoothd|fairplayd|driverkitd' || echo "(无匹配)"

sync
umount "$M" && echo UNMOUNTED

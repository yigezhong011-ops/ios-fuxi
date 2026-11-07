#!/bin/bash
# Pull kernel.macho.adt out of both FAT32 payload volumes for comparison.
set -uo pipefail
W=/root/fuxi/adtcmp
mkdir -p "$W"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

pull() {
  local img=$1 name=$2
  local mnt=$W/$name
  mkdir -p "$mnt"
  if ! mount -t vfat -o loop,ro "$img" "$mnt" 2>/dev/null; then
    echo "  挂载失败: $img"
    return 1
  fi
  if [ -f "$mnt/EFI/UniXNU/Payloads/kernel.macho.adt" ]; then
    cp "$mnt/EFI/UniXNU/Payloads/kernel.macho.adt" "$W/$name.adt"
    echo "  取出 $name.adt  $(stat -c%s "$W/$name.adt") 字节"
  else
    echo "  卷里没有 ADT"
  fi
  umount "$mnt" 2>/dev/null || umount -l "$mnt" 2>/dev/null || true
}

echo "=== 官方 zip 的 payload（之前能跑到 SecurityLock 的那份）==="
pull /mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img theirs

echo "=== 我们刚构建的 payload ==="
pull /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/payload.img ours

ls -l "$W"/*.adt 2>/dev/null

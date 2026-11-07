#!/bin/bash
# List every file in both payload volumes: a GPU addon would be the one artifact
# that lets sheng-fb-gpu / metal work without the author's kernel.
set -uo pipefail
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
M=/root/fuxi/pl
mkdir -p "$M"

for pair in "payload-gpu16.img:gpu16" "expert-payload-vol.img:expert"; do
  img=${pair%%:*}; tag=${pair##*:}
  src=/mnt/e/DSH-Fuxi/$img
  [ -f "$src" ] || src=/root/fuxi/$img
  [ -f "$src" ] || { echo "$img 不存在"; continue; }
  mount -t vfat -o loop,ro "$src" "$M"
  echo "=== $tag ($img) ==="
  find "$M" -type f -printf '  %-56p %10s B\n' | sort
  echo "  --- 目录 ---"
  find "$M" -type d | sed 's|'"$M"'||' | sort | head -10
  umount "$M"
  echo
done

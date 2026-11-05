#!/bin/bash
# Second cleanup pass: the images the cleanup list did not name.
# Reversible: everything goes to 待删除, nothing is deleted.
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi
TRASH=$ROOT/待删除
mkdir -p "$TRASH"

IMAGES=(
  fuxi-csfix-quiet.img fuxi-touch-boot.img
  t32-bl-clean.img t32-iphone14b.img
  t36-bl.img t36-canvas.img t36-cc.img t36-setup1.img
  unixnu-expert-boot.img user-boot.img
)

moved=0; bytes=0
for item in "${IMAGES[@]}"; do
  src=$ROOT/$item
  [ -e "$src" ] || { echo "  跳过（不存在）: $item"; continue; }
  size=$(stat -c%s "$src")
  if mv -f "$src" "$TRASH/$item"; then
    moved=$((moved + 1)); bytes=$((bytes + size))
    printf '  移动 %-28s %7.1f MB\n' "$item" "$(echo "$size" | awk '{print $1/1048576}')"
  fi
done
echo
echo "第二批移动 $moved 项，$(echo "$bytes" | awk '{printf "%.2f", $1/1073741824}') GB"
echo "待删除 现在: $(du -sh "$TRASH" | cut -f1)"

echo
echo "=== DSH-Fuxi 剩下的一级大头 ==="
du -sm "$ROOT"/* 2>/dev/null | awk '$1 >= 90' | sort -rn | while read -r mb p; do
  printf '  %6d MB  %s\n' "$mb" "$(basename "$p")"
done

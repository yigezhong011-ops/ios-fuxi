#!/bin/bash
# Move the analysis leftovers to 待删除 (reversible; the user deletes).
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi
TRASH=$ROOT/待删除
mkdir -p "$TRASH"

echo "=== 移动前 ==="
df -h /mnt/e | tail -1 | sed 's/^/  /'
du -sm "$ROOT/logs/data-raw.img" "$ROOT/dump/root-peek" 2>/dev/null | sed 's/^/  /'
du -sm "$ROOT"/logs/carve-* 2>/dev/null | awk '{s+=$1} END {printf "  carve-* 合计 %d MB\n", s}'

moved=0; bytes=0
move() {
  local src=$1
  [ -e "$src" ] || { echo "  跳过（不存在）: ${src#$ROOT/}"; return; }
  local size dst
  size=$(du -sb "$src" 2>/dev/null | cut -f1)
  dst=$TRASH/${src#$ROOT/}
  mkdir -p "$(dirname "$dst")"
  if mv -f "$src" "$dst"; then
    moved=$((moved+1)); bytes=$((bytes+size))
    printf '  移动 %-42s %8.1f MB\n' "${src#$ROOT/}" "$(echo "$size" | awk '{print $1/1048576}')"
  else
    echo "  失败: ${src#$ROOT/}"
  fi
}

move "$ROOT/logs/data-raw.img"
move "$ROOT/logs/data-list.txt"
for d in "$ROOT"/logs/carve-*; do [ -d "$d" ] && move "$d"; done
move "$ROOT/dump/root-peek"

echo
echo "共移动 $moved 项，$(echo "$bytes" | awk '{printf "%.2f", $1/1073741824}') GB"
echo "待删除 现在 $(du -sh "$TRASH" | cut -f1)"
df -h /mnt/e | tail -1 | sed 's/^/  /'

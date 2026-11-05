#!/bin/bash
# Move the confirmed cleanup set into E:\DSH-Fuxi\待删除, keeping relative paths.
# Nothing is deleted: the user removes 待删除 himself.
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi
TRASH=$ROOT/待删除
mkdir -p "$TRASH"

# A: the images the cleanup list names
IMAGES=(
  t32-bl1.img t32-buttons-daily2.img t32-usb.img
  t32-wall.img t32-wall2.img t32-wall3.img
  t36-bl2-gpu-fix1.img t36-bl2-usb.img t36-bl2-usb2.img
  t36-fdlog.img t36-fdmsd.img
  t36-usb-log3.img t36-usb-msd4.img t36-usb-nosb.img
  t36-usb-trace5.img t36-usb-trace6.img
  t36-usbcpu0.img t36-usbcpu0b.img t36-usbcpu0c.img t36-usbcpu0d.img
  t36-usbcpu0e.img t36-usbcpu0f.img
  t36-usbdiag.img t36-usbdiag2.img
  t50-mine-gpu-bgra.img t50-mine-gpu-fix1.img
)

# B: the extra items the user approved
EXTRAS=(
  logs/twrp-loghang-export.bin
  logs/twrp-daily1-export.bin
  logs/twrp-appshang-export.bin
  pkg/fuxi-ios-working
  pkg/ksrc
  share-2026-10-31
  share-2026-10-30
  fuxi-unixnu-gpu-kernel-2026-10-31.zip
)

# This must never be moved, whatever the list says.
KEEP=(
  t50-mine-gpu-fix.img t50-mine.img t50-mine-gpu-log.img t50-mine-gpu-migrate.img
  t50-mine-gpu-apps.img t50-subtype2556-nodiag.img t36-bl2.img t36-bl2-gpu-fix.img
  t36-setup0.img t36-phone-cache-miss.img t32-bl-daily.img t32-gpu6.img
  keys token2.txt unixnu-build ux-out tools dump logs ci known-good backup
  backup-gpu-first-light share-for-author PATCH-fuxi-usb-power wallpaper-overlay
)

is_keep() {
  local name=$1
  for k in "${KEEP[@]}"; do [ "$name" = "$k" ] && return 0; done
  return 1
}

moved=0; bytes=0; skipped=()
for item in "${IMAGES[@]}" "${EXTRAS[@]}"; do
  src=$ROOT/$item
  base=$(basename "$item")
  if is_keep "$base"; then echo "  拒绝（在保留清单里）: $item"; skipped+=("$item"); continue; fi
  if [ ! -e "$src" ]; then echo "  跳过（不存在）: $item"; continue; fi
  size=$(du -sb "$src" 2>/dev/null | cut -f1)
  dst=$TRASH/$item
  mkdir -p "$(dirname "$dst")"
  if mv -f "$src" "$dst"; then
    moved=$((moved + 1)); bytes=$((bytes + size))
    printf '  移动 %-34s %8.1f MB\n' "$item" "$(echo "$size" | awk '{print $1/1048576}')"
  else
    echo "  移动失败: $item"
  fi
done

echo
echo "共移动 $moved 项，$(echo "$bytes" | awk '{printf "%.2f", $1/1073741824}') GB"
[ ${#skipped[@]} -gt 0 ] && echo "被拒绝 ${#skipped[@]} 项: ${skipped[*]}"
echo
echo "=== 待删除 现在 ==="
du -sh "$TRASH" 2>/dev/null
echo "=== E: 剩余空间 ==="
df -h /mnt/e | tail -1

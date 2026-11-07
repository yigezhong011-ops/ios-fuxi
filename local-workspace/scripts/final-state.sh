#!/bin/bash
# Final state after the deletion: what must still be there.
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi
echo "=== 空间 ==="
df -h /mnt/e | tail -1
echo
echo "=== 保留的镜像 ==="
for f in t50-mine-gpu-fix.img t50-mine.img t50-mine-gpu-log.img t50-mine-gpu-migrate.img \
         t50-mine-gpu-apps.img t50-subtype2556-nodiag.img t36-bl2.img t36-bl2-gpu-fix.img \
         t36-setup0.img t36-phone-cache-miss.img t32-bl-daily.img t32-gpu6.img; do
  [ -f "$ROOT/$f" ] && printf '  ✓ %s\n' "$f" || printf '  ✗ 缺失 %s\n' "$f"
done
echo
echo "=== 关键目录/文件 ==="
for d in keys token2.txt unixnu-build ux-out tools dump/wsl dump/root-peek logs ci known-good \
         backup backup-gpu-first-light share-for-author PATCH-fuxi-usb-power wallpaper-overlay; do
  [ -e "$ROOT/$d" ] && printf '  ✓ %s\n' "$d" || printf '  ✗ 缺失 %s\n' "$d"
done
echo
echo "=== 待删除 是否已空 ==="
ls -A "$ROOT/待删除" 2>/dev/null | wc -l
echo "=== 删除清单 ==="
ls -l "$ROOT/deleted-2026-11-04.txt" 2>/dev/null
echo
echo "=== 根目录 .md 文档 ==="
ls "$ROOT"/*.md 2>/dev/null | wc -l

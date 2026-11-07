#!/bin/bash
# Verify the cleanup: keeps intact, trash populated, nothing outside the list touched.
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi

echo "=== 必须保留的 12 个镜像 ==="
for f in t50-mine-gpu-fix.img t50-mine.img t50-mine-gpu-log.img t50-mine-gpu-migrate.img \
         t50-mine-gpu-apps.img t50-subtype2556-nodiag.img t36-bl2.img t36-bl2-gpu-fix.img \
         t36-setup0.img t36-phone-cache-miss.img t32-bl-daily.img t32-gpu6.img; do
  [ -f "$ROOT/$f" ] && printf '  ✓ %-32s %6.1f MB\n' "$f" "$(stat -c%s "$ROOT/$f" | awk '{print $1/1048576}')" \
                    || printf '  ✗ 缺失: %s\n' "$f"
done

echo
echo "=== 关键目录仍在 ==="
for d in keys unixnu-build ux-out tools dump/wsl dump/root-peek logs ci known-good backup \
         share-for-author PATCH-fuxi-usb-power wallpaper-overlay; do
  [ -d "$ROOT/$d" ] && printf '  ✓ %s\n' "$d" || printf '  ✗ 缺失: %s\n' "$d"
done
[ -f "$ROOT/token2.txt" ] && echo "  ✓ token2.txt" || echo "  ✗ token2.txt 缺失"

echo
echo "=== logs/ 里原来的 .bin 还在吗（只应删掉 3 个 export）==="
ls "$ROOT/logs"/*.bin 2>/dev/null | wc -l
ls "$ROOT/logs"/*export.bin 2>/dev/null | wc -l

echo
echo "=== 待删除 结构（前 20 项）==="
find "$ROOT/待删除" -maxdepth 2 | head -22 | sed "s|$ROOT/||"
echo
echo "待删除 总大小: $(du -sh "$ROOT/待删除" | cut -f1)"

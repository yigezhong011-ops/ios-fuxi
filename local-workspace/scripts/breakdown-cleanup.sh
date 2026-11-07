#!/bin/bash
# Break down the big subdirectories so the user can decide item by item.
set -uo pipefail
echo "=== dump/ 子目录 > 100 MB ==="
du -sm /mnt/e/DSH-Fuxi/dump/* 2>/dev/null | awk '$1 >= 100' | sort -rn | while read -r mb p; do
  printf '  %7d MB  dump/%s\n' "$mb" "$(basename "$p")"
done

echo
echo "=== pkg/ 子目录 > 50 MB ==="
du -sm /mnt/e/DSH-Fuxi/pkg/* 2>/dev/null | awk '$1 >= 50' | sort -rn | while read -r mb p; do
  printf '  %7d MB  pkg/%s\n' "$mb" "$(basename "$p")"
done

echo
echo "=== logs/ 内容 ==="
du -sm /mnt/e/DSH-Fuxi/logs/* 2>/dev/null | sort -rn | head -12 | while read -r mb p; do
  printf '  %7d MB  logs/%s\n' "$mb" "$(basename "$p")"
done

echo
echo "=== 备份/分享类目录 ==="
for d in backup backup-gpu-first-light share-2026-10-31 share-2026-10-30 known-good ci-fail; do
  [ -d "/mnt/e/DSH-Fuxi/$d" ] && printf '  %7s MB  %s\n' "$(du -sm "/mnt/e/DSH-Fuxi/$d" | cut -f1)" "$d"
done

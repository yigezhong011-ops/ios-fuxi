#!/bin/bash
# Same checks as before, on the carve taken right after a boot of the daily image with the new plugin.
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
B=/mnt/e/DSH-Fuxi/logs/carve-wallnew/log.bin
echo "=== 统一日志（lscan）计数 ==="
for k in 'CMPhotoCompressionSessionAddImage' 'hvc1' 'unableToFinalizeImageDestination' \
         'PRBPoster' 'GalleryCache' 'PosterBoard' 'no linear image' 'Wallpaper'; do
  printf '  %-40s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== 内核窗口里的 FUXI120 / coherence ==="
tr -d '\0' < "$B" | grep -a -o 'FUXI120[^\n]*' | tail -8 | cut -c1-120
tr -d '\0' < "$B" | grep -a -o '\[coherence\][^\n]*' | tail -3 | cut -c1-160
echo
echo "=== GalleryCache 路径（去重）==="
grep -a 'GalleryCache' "$L" | sort -u | head -5 | cut -c1-230

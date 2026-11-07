#!/bin/bash
# Search the carved unified-log strings for the wallpaper / HEVC evidence.
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-coh2/lscan.txt
echo "=== 次数统计 ==="
for k in 'CMPhotoCompressionSessionAddImage' 'hvc1' '12782' 'unableToFinalizeImageDestination' \
         'PRBPoster' 'PosterBoard' 'PBFPosterExtensionDataStore' 'data store could not be created' \
         'Wallpaper' 'no linear image'; do
  printf '  %-42s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== CMPhoto / hvc1 的具体行（前 8 条）==="
grep -a -m 8 -E 'CMPhotoCompression|hvc1|12782' "$L" | cut -c1-200
echo
echo "=== PosterBoard / DataStore 的具体行（前 8 条）==="
grep -a -m 8 -E 'PRBPoster|data store could not be created|PBFPosterExtensionDataStore' "$L" | cut -c1-200
echo
echo "=== no linear image（前 5 条）==="
grep -a -m 5 'no linear image' "$L" | cut -c1-200

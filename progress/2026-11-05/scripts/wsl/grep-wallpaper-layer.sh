#!/bin/bash
# Who publishes the wallpaper layer, and why is it hidden?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== 相关服务/组件出现次数 ==="
for k in 'SBRendererService' 'SBRenderer' 'WallpaperRenderer' 'PRSPoster' 'activePoster' \
         'selectedConfiguration' 'posterPath' 'WallpaperKit' 'SBSWallpaper' 'CSWallpaperComponent'; do
  printf '  %-28s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== CSWallpaperComponent 的不同状态（去重，前 10）==="
grep -ao 'CSWallpaperComponent:[^>]*>' "$L" | sed 's/0x[0-9a-f]*/0xX/' | sort | uniq -c | sort -rn | head -10
echo
echo "=== 含 hidden: YES 的行是否都带 alpha 0 ==="
grep -ac 'hidden: YES; alpha: 0.00' "$L" || true
grep -ac 'hidden: NO' "$L" || true

#!/bin/bash
# Is the wallpaper component ever visible? And how do the two identifiers differ?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== Wallpaper 组件里 hidden: NO 的行数 ==="
grep -ao 'CSWallpaperComponent:[^>]*hidden: NO[^>]*>' "$L" | wc -l
echo "=== Wallpaper 组件里 hidden: YES 的行数 ==="
grep -ao 'CSWallpaperComponent:[^>]*hidden: YES[^>]*>' "$L" | wc -l
echo
echo "=== 任意组件 hidden: NO 的样本（前 3 个，看是什么类型）==="
grep -ao '<CS[A-Za-z]*Component:[^>]*hidden: NO[^>]*>' "$L" | sed 's/0x[0-9a-f]*/0xX/' | sort -u | head -3 | cut -c1-190
echo
echo "=== identifier: (active) 与 (default) 的完整样本 ==="
grep -ao 'CSWallpaperComponent:[^>]*identifier: (active)[^>]*>' "$L" | head -1 | cut -c1-190
grep -ao 'CSWallpaperComponent:[^>]*identifier: (default)[^>]*>' "$L" | head -1 | cut -c1-190

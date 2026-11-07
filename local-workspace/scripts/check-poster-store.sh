#!/bin/bash
# Does the poster data store have any files on disk? Look for its own file names.
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== poster 存储可能包含的文件名（去重）==="
for pat in 'PBFPosterConfiguration' 'PosterConfigurationStore' 'PosterBoard.sqlite' 'posterStore' \
           'DataStore.sqlite' 'switcherConfiguration' 'PosterDescriptor' 'GalleryCache'; do
  n=$(grep -ac "$pat" "$L" 2>/dev/null || echo 0)
  printf '  %-28s %s\n' "$pat" "$n"
done
echo
echo "=== 含 PBFPosterConfiguration 的字符串（前 10，去重）==="
grep -aoE '[A-Za-z0-9_./-]*PBFPoster[A-Za-z0-9_.]*' "$L" | sort -u | head -10 | cut -c1-180
echo
echo "=== GalleryCache 附近的可打印串（原始上下文）==="
grep -a 'GalleryCache' "$L" | head -2 | cut -c1-300

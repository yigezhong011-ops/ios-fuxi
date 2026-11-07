#!/bin/bash
# E: free space, top-level directory sizes under DSH-Fuxi, and large non-image files.
set -uo pipefail
echo "=== E: 空间 ==="
df -h /mnt/e | tail -2

echo
echo "=== E:\\DSH-Fuxi 一级目录（大于 100 MB 的）==="
du -sm /mnt/e/DSH-Fuxi/* 2>/dev/null | awk '$1 >= 100' | sort -rn | while read -r mb path; do
  printf '  %7d MB  %s\n' "$mb" "$(basename "$path")"
done

echo
echo "=== 大文件（>150 MB，非 .img）==="
find /mnt/e/DSH-Fuxi -maxdepth 2 -type f -size +150M ! -name '*.img' 2>/dev/null |
  head -20 | while read -r f; do printf '  %7.0f MB  %s\n' "$(stat -c%s "$f" | awk '{print $1/1048576}')" "${f#/mnt/e/DSH-Fuxi/}"; done

echo
echo "=== 待删除 现状 ==="
ls -la /mnt/e/DSH-Fuxi/待删除 2>/dev/null | head -8

#!/bin/bash
# Full picture of where the space on E: actually goes.
set -uo pipefail
echo "=== E: 顶层目录（GB）==="
du -sm /mnt/e/* 2>/dev/null | awk '$1 >= 200' | sort -rn | while read -r mb p; do
  printf '  %8.2f GB  %s\n' "$(echo "$mb" | awk '{print $1/1024}')" "$(basename "$p")"
done

echo
echo "=== DSH-Fuxi 内部全部一级子项（MB，>=50）==="
du -sm /mnt/e/DSH-Fuxi/* 2>/dev/null | awk '$1 >= 50' | sort -rn | while read -r mb p; do
  printf '  %8d MB  %s\n' "$mb" "$(basename "$p")"
done

echo
echo "=== DSH-Fuxi 里 > 200 MB 的单个文件 ==="
find /mnt/e/DSH-Fuxi -type f -size +200M 2>/dev/null | while read -r f; do
  printf '  %8.1f MB  %s\n' "$(stat -c%s "$f" | awk '{print $1/1048576}')" "${f#/mnt/e/DSH-Fuxi/}"
done | sort -rn | head -25

echo
echo "=== E:\\WSL 内部（只读查看，不动）==="
du -sm /mnt/e/WSL/* 2>/dev/null | sort -rn | head -8 | while read -r mb p; do
  printf '  %8.2f GB  %s\n' "$(echo "$mb" | awk '{print $1/1024}')" "$(basename "$p")"
done
find /mnt/e/WSL -maxdepth 3 -type f -size +1G 2>/dev/null | while read -r f; do
  printf '  %8.2f GB  %s\n' "$(stat -c%s "$f" | awk '{print $1/1073741824}')" "${f#/mnt/e/WSL/}"
done | head -10

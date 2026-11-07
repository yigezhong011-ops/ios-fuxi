#!/bin/bash
# Current disk pressure and the files the handoff says to deal with first.
set -uo pipefail
echo "=== E: 空间 ==="
df -h /mnt/e | tail -1
echo
echo "=== 大文件 ==="
for f in /mnt/e/DSH-Fuxi/logs/data-raw.img /mnt/e/DSH-Fuxi/logs/data-list.txt; do
  [ -e "$f" ] && printf '  %8.2f GB  %s\n' "$(stat -c%s "$f" | awk '{print $1/1073741824}')" "${f#/mnt/e/DSH-Fuxi/}"
done
du -sh /mnt/e/DSH-Fuxi/dump/root-peek 2>/dev/null | sed 's/^/  /'
echo
echo "=== logs 目录内容（前 15 大）==="
du -sm /mnt/e/DSH-Fuxi/logs/* 2>/dev/null | sort -rn | head -15 | while read -r mb p; do
  printf '  %6d MB  %s\n' "$mb" "$(basename "$p")"
done
echo
echo "=== WSL 内部磁盘占用 ==="
df -h / | tail -1
du -sh /root/hakios-xnu-kernel /root/build /root/fuxi 2>/dev/null | sed 's/^/  /'
echo
echo "=== 交接提到的工具是否在 ==="
for f in /mnt/e/DSH-Fuxi/dump/wsl/lscan-arm64 /mnt/e/DSH-Fuxi/dump/wsl/pull-wall.ps1 \
         /mnt/e/DSH-Fuxi/dump/wsl/read-wall1.py /mnt/e/DSH-Fuxi/dump/wsl/read-dsc-xref.py; do
  [ -e "$f" ] && echo "  ✓ $(basename "$f")" || echo "  ✗ 缺 $(basename "$f")"
done

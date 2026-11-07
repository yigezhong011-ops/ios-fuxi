#!/bin/bash
# Delete the confirmed set (the user asked for all of it). A manifest is written first so
# everything that disappears is still identifiable (the MIUI package can be re-downloaded).
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi
TRASH=$ROOT/待删除
MANIFEST=$ROOT/deleted-2026-11-04.txt

echo "=== 删除前空间 ==="
df -h /mnt/e | tail -1

{
  echo "# 2026-11-04 删除清单"
  echo
  echo "## 待删除/ 全部内容"
  find "$TRASH" -mindepth 1 -maxdepth 1 -printf '%10s  %p\n' 2>/dev/null | sort -k2
  echo
  echo "## 根目录孤立文件"
  ls -l /mnt/e/L2859.png 2>/dev/null
  echo
  echo "## 小米线刷包"
  find '/mnt/e/iOS小米13' -maxdepth 2 -printf '%10s  %p\n' 2>/dev/null | sort -k2 | head -40
  echo
  echo "## logs 里的 TWRP 导出"
  ls -l $ROOT/logs/twrp-oslog1-export.bin 2>/dev/null
} > "$MANIFEST"
echo "清单已写入 $MANIFEST（$(wc -l < "$MANIFEST") 行）"

freed=0
size_of() { [ -e "$1" ] && du -sb "$1" 2>/dev/null | cut -f1 || echo 0; }

echo
echo "=== 删除 待删除/ 内容 ==="
n=0
while IFS= read -r -d '' p; do
  s=$(size_of "$p")
  rm -rf -- "$p" && { n=$((n+1)); freed=$((freed+s)); }
done < <(find "$TRASH" -mindepth 1 -maxdepth 1 -print0 2>/dev/null)
echo "  删掉 $n 项"

for f in /mnt/e/L2859.png /mnt/e/iOS小米13 "$ROOT/logs/twrp-oslog1-export.bin"; do
  if [ -e "$f" ]; then
    s=$(size_of "$f")
    rm -rf -- "$f" && { freed=$((freed+s)); printf '  删除 %-32s %7.1f MB\n' "$(basename "$f")" "$(echo "$s" | awk '{print $1/1048576}')"; }
  fi
done

echo
echo "共释放 $(echo "$freed" | awk '{printf "%.2f", $1/1073741824}') GB"
echo "=== 删除后空间 ==="
df -h /mnt/e | tail -1

#!/bin/bash
# The Darwin userland 16.5 IPSW HakiOS builds its system image from (6.17 GB).
set -uo pipefail
DIR=/mnt/e/DSH-Fuxi/ipsw16.5
OUT="$DIR/iPhone10,3,iPhone10,6_16.5_20F66_Restore.ipsw"
URL='https://updates.cdn-apple.com/2023SpringFCS/fullrestores/032-85130/6AB0D10A-8AF9-4F6C-8CF5-A1B315CABE88/iPhone10,3,iPhone10,6_16.5_20F66_Restore.ipsw'
mkdir -p "$DIR"
echo "=== 目标 $OUT ==="
for i in 1 2 3 4 5; do
  curl -L -C - --retry 5 --retry-delay 5 -o "$OUT" "$URL" 2>&1 | tail -2
  SIZE=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
  echo "  第 $i 次结束，已下载 $SIZE 字节"
  if [ "$SIZE" -ge 6165698198 ]; then echo "下载完整"; break; fi
  sleep 5
done
ls -lh "$OUT"
sha256sum "$OUT" | cut -c1-40

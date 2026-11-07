#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
RAW=/root/fuxi/root-gles.raw
OUT=/mnt/e/DSH-Fuxi/gles-root.simg
ART=/mnt/e/DSH-Fuxi/gles-stack

echo "=== 1/4 转 raw（若已存在则跳过）==="
if [ ! -f "$RAW" ]; then
  simg2img "$P/ios16-root-v11-fixed.simg" "$RAW"
fi
ls -lh "$RAW"

echo "=== 2/4 stage（装库 + 注入 backboardd）==="
bash /mnt/e/DSH-Fuxi/dump/wsl/stage-mesa-root.sh "$RAW" "$ART" --inject 2>&1 | tail -25

echo "=== 3/4 转回稀疏镜像 ==="
which img2simg || { echo "no img2simg"; exit 1; }
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
echo "=== 4/4 完成 ==="
sha256sum "$OUT" | cut -c1-32

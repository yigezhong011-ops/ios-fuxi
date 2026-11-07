#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
echo "=== simg 稀疏头（28B）+ 第一个 chunk 头（12B）==="
xxd -l 48 "$P/ios16-root-v11.simg"
echo
echo "=== 卷头应在 28+12+0x400 = 1080 之前，检查 1064 ==="
xxd -l 16 -s 1064 "$P/ios16-root-v11.simg"
echo
echo "=== boot 镜像里 SWEETXNU 的位置 ==="
grep -abo 'SWEETXNU' "$P/boot-gpu3-v4.img" | head -5

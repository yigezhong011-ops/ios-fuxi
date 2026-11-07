#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
echo "=== 转换稀疏镜像 ==="
time simg2img "$P/ios16-root-v11.simg" "$P/ios16-root-v11.raw"
ls -l "$P/ios16-root-v11.raw"
echo "=== 卷头检查（HFS+）==="
xxd -l 16 -s 1024 "$P/ios16-root-v11.raw"
echo "=== fsck ==="
fsck.hfsplus -n "$P/ios16-root-v11.raw" 2>&1 | tail -3

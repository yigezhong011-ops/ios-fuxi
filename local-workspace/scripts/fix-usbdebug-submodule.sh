#!/bin/bash
# The device repo pins a QcomXnuUsbDebug commit that no longer exists upstream
# (the repository was rewritten). Clone what is there and re-point the gitlink.
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/fuxi
PATH_DIR=drivers/QcomXnuUsbDebug
URL=https://github.com/xiaoleGun/QcomXnuUsbDebug.git

rm -rf "$PATH_DIR"
echo "== 克隆到 $PATH_DIR"
git clone "$URL" "$PATH_DIR" 2>&1 | tail -2
NEWSHA=$(git -C "$PATH_DIR" rev-parse HEAD)
echo "== 上游 HEAD: $NEWSHA"

# 让父仓库记录新的 gitlink，避免 fetch 再次去找那个不存在的提交
git update-index --add --cacheinfo 160000,"$NEWSHA","$PATH_DIR" 2>&1 | head -3
git -c advice.detachedHead=false status --short "$PATH_DIR" 2>&1 | head -3
echo "== 已更新 gitlink"

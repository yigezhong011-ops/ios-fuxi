#!/bin/bash
# Build HakiOS's loader into our working fuxi Mu-Silicium tree.
set -uo pipefail
LOG=/root/uefi-hakios.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

SRC=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
W=/root/uefi-hak-fuxi
if [ ! -d "$W" ]; then
  echo "--- 复制树 ---"
  cp -a "$SRC" "$W"
fi
cd "$W" || exit 1

echo "--- HakiOS 的文件 ---"
ls /root/hakios-uefi/files 2>/dev/null
find /root/hakios-uefi/files -name '*.c' -o -name '*.h' 2>/dev/null | head -10

echo "--- 打补丁 ---"
if git apply --check --whitespace=nowarn /root/hakios-uefi/hakios.patch 2>/dev/null; then
  git apply --whitespace=nowarn /root/hakios-uefi/hakios.patch && echo "补丁已应用"
else
  echo "补丁已应用或无法应用"
fi

echo "--- 复制 HakiOS 的 files/ ---"
cp -r /root/hakios-uefi/files/. "$W/" 2>/dev/null && echo "files 已复制"

echo "--- 依赖 ---"
[ -x ./setup_env.sh ] && ./setup_env.sh -p apt 2>&1 | tail -8 || echo "没有 setup_env.sh"

echo "--- 构建 ---"
python3 build_uefi.py -d fuxi -r RELEASE 2>&1 | tail -40

echo "=== 结果 ==="
find "$W" -name 'SILICIUM_UEFI.fd' -newermt '-2 hours' 2>/dev/null | head -5
ls -l Build/fuxiPkg/*/FV/SILICIUM_UEFI.fd 2>/dev/null
echo "=== $(date) 结束 ==="

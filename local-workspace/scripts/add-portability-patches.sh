#!/bin/bash
# The remaining portability patches (arm64 crypto asm, kalloc builtins, iig
# forwarders, link shims) belong in the device repository's patch series, which
# is what the build applies.
set -uo pipefail
SRC=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/patches/xnu
DEV=/root/fuxi/fork-device
DST=$DEV/patches/xnu
mkdir -p "$DST"

echo "=== 现有补丁数 ==="
ls "$DST" | wc -l
echo "=== 需要补的 ==="
for p in "$SRC"/*.patch; do
  n=$(basename "$p")
  if [ -f "$DST/$n" ]; then
    echo "  已有 $n"
  else
    cp "$p" "$DST/$n"
    echo "  + $n"
  fi
done
ls "$DST" | wc -l

cd "$DEV"
git -c user.name=dsh -c user.email=dsh@local add patches/xnu 2>/dev/null
git -c user.name=dsh -c user.email=dsh@local commit -q -m "patches: add the xnu portability patches the Linux build needs" 2>/dev/null || echo "（无改动可提交）"
git push -q origin old 2>/dev/null && echo "已推送" || echo "推送跳过"

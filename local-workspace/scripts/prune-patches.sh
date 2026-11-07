#!/bin/bash
# Keep only the portability patches the Linux build actually needs; the IIG and
# link-shim patches collide with UniXNU's own IOKit changes.
set -uo pipefail
DEV=/root/fuxi/fork-device
DST=$DEV/patches/xnu

for p in iig-method-forwarders.patch linux-link-shims.patch; do
  if [ -f "$DST/$p" ]; then
    rm -f "$DST/$p"
    echo "移除 $p"
  fi
done
echo "=== 保留的 3 个 ==="
ls "$DST" | grep -E 'linux-host-tools|crypto-asm|kalloc' 

cd "$DEV"
git -c user.name=dsh -c user.email=dsh@local add -A patches/xnu
git -c user.name=dsh -c user.email=dsh@local commit -q -m "patches: keep only the portability patches that do not collide with IOKit" 2>/dev/null || true
git push -q origin old 2>/dev/null && echo "已推送" || true

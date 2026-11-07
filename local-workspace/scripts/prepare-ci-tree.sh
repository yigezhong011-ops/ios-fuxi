#!/bin/bash
# Prepare the exact tree CI sees, then derive the stub patch from its bsd_init.c.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true
DEV=/root/fuxi/fork-device
OUT=/root/ux3
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
echo "=== 让树把 XNU 源码取下来并打完补丁（预期在链接处失败）==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j8 > /root/ux3-build.log 2>&1
echo "exit=$?"
F=$OUT/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c
if [ -f "$F" ]; then
  echo "找到 bsd_init.c: $(wc -l < "$F") 行"
  echo "=== 末尾 5 行 ==="
  tail -5 "$F"
else
  echo "没有 bsd_init.c"
  tail -5 /root/ux3-build.log
fi

#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-clean.img
M=/root/fuxi/mnt/stage
SRC=/mnt/e/DSH-Fuxi/ci/metal
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$M"
cd /root/ios-fuxi
echo "=== 用官方工具 stage（含 --enable-backboardd）==="
python3 tools/stage-fuxi-metal.py "$M" \
  "$SRC/libmetal2vulkan.dylib" \
  "$SRC/FuxiMetal.bundle" \
  "$SRC/fuxi-metal-smoke" \
  --clients tools/metal-clients.conf \
  --ca-smoke "$SRC/fuxi-ca-smoke" \
  --metallib "$SRC/metal-smoke.metallib" \
  --enable-backboardd 2>&1 | tail -12
echo "=== 结果检查 ==="
ls -la "$M/private/var/db/fuxi-metal" 2>/dev/null
cat "$M/usr/local/share/fuxi/metal-clients.conf" 2>/dev/null
sync
umount "$M"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo STAGE_OK

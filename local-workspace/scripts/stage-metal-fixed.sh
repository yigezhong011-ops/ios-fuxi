#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-clean.img
M=/root/fuxi/mnt/stage2
SRC=/mnt/e/DSH-Fuxi/ci/metal
ICD=/mnt/e/DSH-Fuxi/ci/mesa/libvulkan_freedreno.dylib
[ -f "$ICD" ] || { echo "缺 ICD 文件"; exit 1; }
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$M"
cd /root/ios-fuxi
echo "=== 清掉惩罚记录 ==="
rm -rf "$M/private/var/db/fuxi-metal/backboardd-501"
echo "=== 正确 stage（ICD + translator + backboardd）==="
python3 tools/stage-fuxi-metal.py "$M" \
  "$ICD" \
  "$SRC/FuxiMetal.bundle" \
  "$SRC/fuxi-metal-smoke" \
  --translator "$SRC/libmetal2vulkan.dylib" \
  --ca-smoke "$SRC/fuxi-ca-smoke" \
  --metallib "$SRC/metal-smoke.metallib" \
  --source "$SRC/metal2vulkan-source.tar.gz" \
  --clients tools/metal-clients.conf \
  --enable-backboardd 2>&1 | tail -12
echo "=== 检查 ==="
ls -l "$M/usr/local/lib/" | head -5
cat "$M/usr/local/share/fuxi/metal-clients.conf" | tail -3
ls -la "$M/private/var/db/fuxi-metal/" 2>/dev/null
sync
umount "$M"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo STAGE2_OK

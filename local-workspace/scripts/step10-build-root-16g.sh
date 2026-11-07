#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-root3.log) 2>&1
cd /root/fuxi

echo "=== 清理上次残留 ==="
umount -l /root/fuxi/testmnt 2>/dev/null || true
for m in $(mount | awk '/hfsplus|apfs-fuse/{print $3}' | sort -r); do
  umount -l "$m" 2>/dev/null || true
done
mount | grep -iE 'hfsplus|apfs' || echo "(no leftover mounts)"

echo "=== 估算源体积 ==="
mkdir -p /root/fuxi/mnt/os /root/fuxi/mnt/sysos /root/fuxi/mnt/appos
apfs-fuse /root/fuxi/ipsw/087-86698-044.dmg /root/fuxi/mnt/os 2>/dev/null || true
apfs-fuse /root/fuxi/ipsw/087-86593-047.dmg /root/fuxi/mnt/sysos 2>/dev/null || true
apfs-fuse /root/fuxi/ipsw/087-86715-047.dmg /root/fuxi/mnt/appos 2>/dev/null || true
du -sh /root/fuxi/mnt/os/root /root/fuxi/mnt/sysos/root /root/fuxi/mnt/appos/root 2>/dev/null || true
umount -l /root/fuxi/mnt/os /root/fuxi/mnt/sysos /root/fuxi/mnt/appos 2>/dev/null || true

echo "=== 重建 16G 根镜像 ==="
rm -f /root/fuxi/iosroot.img
date
bash /root/fuxi/mkiosroot.sh \
  /root/fuxi/ipsw/087-86698-044.dmg \
  /root/fuxi/ipsw/087-86593-047.dmg \
  /root/fuxi/ipsw/087-86715-047.dmg \
  /root/fuxi/iosroot.img 16G
date
ls -lh /root/fuxi/iosroot.img
echo "BUILD_ROOT_OK"

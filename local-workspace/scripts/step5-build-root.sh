#!/bin/bash
set -euo pipefail
cd /root/fuxi
exec > >(tee /root/fuxi/build-root.log) 2>&1

echo "=== 准备 apfs-fuse 与 mkiosroot.sh ==="
ln -sf /root/apfs-fuse/build/apfs-fuse /usr/local/bin/apfs-fuse
which apfs-fuse mkfs.hfsplus fsck.hfsplus rsync
curl -fsSL https://raw.githubusercontent.com/bangprovn/ios-fuxi/main/tools/mkiosroot.sh -o /root/fuxi/mkiosroot.sh
chmod +x /root/fuxi/mkiosroot.sh
echo "=== 开始构建 HFS+ 根镜像（9G）==="
rm -f /root/fuxi/iosroot.img
date
bash /root/fuxi/mkiosroot.sh \
  /root/fuxi/ipsw/087-86698-044.dmg \
  /root/fuxi/ipsw/087-86593-047.dmg \
  /root/fuxi/ipsw/087-86715-047.dmg \
  /root/fuxi/iosroot.img 9G
date
ls -lh /root/fuxi/iosroot.img
echo "BUILD_ROOT_DONE"

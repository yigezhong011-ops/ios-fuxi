#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-root2.log) 2>&1
cd /root/fuxi
echo "=== hfsplus 支持检查 ==="
grep -i hfs /proc/filesystems || { echo "NO HFSPLUS"; exit 1; }
mkdir -p /root/fuxi/testmnt
rm -f /root/fuxi/t.img
truncate -s 64M /root/fuxi/t.img
mkfs.hfsplus -s -J -v t /root/fuxi/t.img >/dev/null 2>&1
mount -t hfsplus -o loop /root/fuxi/t.img /root/fuxi/testmnt
touch /root/fuxi/testmnt/x && ls /root/fuxi/testmnt && umount /root/fuxi/testmnt
rm -f /root/fuxi/t.img
echo "=== 开始建 9G 根镜像 ==="
rm -f /root/fuxi/iosroot.img
date
bash /root/fuxi/mkiosroot.sh \
  /root/fuxi/ipsw/087-86698-044.dmg \
  /root/fuxi/ipsw/087-86593-047.dmg \
  /root/fuxi/ipsw/087-86715-047.dmg \
  /root/fuxi/iosroot.img 9G
date
ls -lh /root/fuxi/iosroot.img
df -h /root/fuxi/iosroot.img
echo "BUILD_ROOT_OK"

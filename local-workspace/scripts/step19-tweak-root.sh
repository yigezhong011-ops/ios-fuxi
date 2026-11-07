#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/tweak-root.log) 2>&1
cd /root/fuxi

echo "=== 检查本地镜像 ==="
ls -lh /root/fuxi/iosroot.img 2>/dev/null || { echo "本地镜像不存在"; exit 1; }

echo "=== fsck 后挂载 ==="
for m in $(mount | awk '/hfsplus/{print $3}' | sort -r); do umount -l "$m" 2>/dev/null || true; done
fsck.hfsplus -f -y /root/fuxi/iosroot.img 2>&1 | grep -v 'Illegal name' | tail -3 || true
mkdir -p /root/fuxi/mnt/tweak
mount -t hfsplus -o loop,force,rw /root/fuxi/iosroot.img /root/fuxi/mnt/tweak
R=/root/fuxi/mnt/tweak
ls "$R" | head -5

echo "=== 跑 sweet-root-tweaks.py ==="
cd /root/ios-fuxi
python3 tools/sweet-root-tweaks.py /root/fuxi/mnt/tweak 2>&1 | tail -25 || echo "TWEAK_FAILED=$?"

echo "=== 校验关键产物 ==="
ls -ld "$R/private/var/containers" "$R/private/var/containers/Bundle" "$R/private/var/containers/Data/System" 2>&1
grep -c 'CrasX' "$R/System/Library/xpc/launchd.plist" 2>/dev/null || true

echo "=== 卸载 + fsck ==="
sync
umount "$R"
fsck.hfsplus -f -y /root/fuxi/iosroot.img 2>&1 | grep -v 'Illegal name' | tail -3 || true
cp /root/fuxi/iosroot.img /mnt/e/DSH-Fuxi/dump/iosroot-tweaked.img
ls -lh /mnt/e/DSH-Fuxi/dump/iosroot-tweaked.img
echo TWEAK_DONE

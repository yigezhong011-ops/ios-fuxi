#!/bin/bash
set -uo pipefail
exec > >(tee /root/fuxi/sys-root.log) 2>&1
cd /root/fuxi

IMG=/root/fuxi/iosroot.img
ls -lh "$IMG" || exit 1

for m in $(mount | awk '/hfsplus/{print $3}' | sort -r); do umount -l "$m" 2>/dev/null || true; done
fsck.hfsplus -f -y "$IMG" 2>&1 | grep -v 'Illegal name' | tail -2 || true
mkdir -p /root/fuxi/mnt/sys
mount -t hfsplus -o loop,force,rw "$IMG" /root/fuxi/mnt/sys || { echo MOUNT_FAILED; exit 1; }
R=/root/fuxi/mnt/sys

cd /root/ios-fuxi
echo "=== dry-run ==="
python3 tools/fuxi-sys-root.py --dry-run --quiet-jobs observed "$R" 2>&1 | tail -20
echo "=== apply ==="
python3 tools/fuxi-sys-root.py --quiet-jobs observed "$R" 2>&1 | tail -20

echo "=== 校验：被禁用的任务 ==="
grep -A2 '_FuxiSysDisabled' "$R/System/Library/xpc/launchd.plist" 2>/dev/null | head -10 || true

sync
umount "$R"
fsck.hfsplus -f -y "$IMG" 2>&1 | grep -v 'Illegal name' | tail -2 || true
cp "$IMG" /mnt/e/DSH-Fuxi/dump/iosroot-sys.img
ls -lh /mnt/e/DSH-Fuxi/dump/iosroot-sys.img
echo SYS_ROOT_DONE

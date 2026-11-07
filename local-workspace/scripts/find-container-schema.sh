#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/schema
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
echo "=== System 容器列表 ==="
ls "$M/private/var/containers/Data/System" 2>/dev/null | head -8
echo
echo "=== 找一个样板 metadata ==="
F=$(find "$M/private/var/containers/Data/System" -name '.com.apple.mobile_container_manager.metadata.plist' 2>/dev/null | head -1)
echo "样板: $F"
[ -n "$F" ] && python3 -c "
import plistlib,sys
d=plistlib.load(open('$F','rb'))
for k,v in d.items(): print(k,'=',repr(v)[:90])
"
echo
echo "=== 是否已有 mobileactivationd ==="
grep -rl 'com.apple.mobileactivationd' "$M/private/var/containers" 2>/dev/null | head -3 || echo "(无)"
umount "$M" 2>/dev/null || true

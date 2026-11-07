#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/jobs
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
echo "=== launchd.plist 是否存在 ==="
ls -l "$M/System/Library/xpc/launchd.plist" 2>/dev/null || echo "(无)"
echo
echo "=== 里面有哪些相关 job ==="
for j in bluetoothd fairplayd driverkitd CommCenter; do
  n=$(python3 -c "
import plistlib
d=plistlib.load(open('$M/System/Library/xpc/launchd.plist','rb'))
keys=list(d.keys()) if isinstance(d,dict) else []
print(sum(1 for k in keys if '$j' in k))
" 2>/dev/null || echo 0)
  echo "$j: $n"
done
echo
echo "=== 顶层结构 ==="
python3 -c "
import plistlib
d=plistlib.load(open('$M/System/Library/xpc/launchd.plist','rb'))
print('type:', type(d).__name__, 'entries:', len(d))
ks=list(d.keys())[:8]
print('sample keys:', ks)
" 2>&1 | head -5
umount "$M" 2>/dev/null || true

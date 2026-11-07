#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/jobs
mkdir -p "$M"
mount -t hfsplus -o loop,ro,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }
python3 - <<PY
import plistlib
d = plistlib.load(open('$M/System/Library/xpc/launchd.plist','rb'))
ld = d.get('LaunchDaemons', {})
print('LaunchDaemons 条目:', len(ld))
for name in ('com.apple.bluetoothd', 'com.apple.fairplayd.H2', 'com.apple.driverkitd', 'com.apple.CommCenter'):
    hit = [k for k in ld if name in k]
    print(f'{name}: {hit[:3] if hit else "—"}')
print()
print('样例条目字段:', list(list(ld.values())[0].keys())[:8] if ld else 'none')
PY
umount "$M" 2>/dev/null || true

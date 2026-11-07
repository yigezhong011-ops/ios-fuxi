#!/bin/bash
set -euo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/jobs
mkdir -p "$M"
mount -t hfsplus -o loop,rw,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }

python3 - <<PY
import plistlib, pathlib
p = pathlib.Path('$M/System/Library/xpc/launchd.plist')
d = plistlib.load(open(p, 'rb'))
ld = d['LaunchDaemons']
before = len(ld)
removed = []
for key in list(ld.keys()):
    if any(s in key for s in ('bluetoothd', 'fairplayd', 'driverkitd')):
        removed.append(key)
        del ld[key]
p.write_bytes(plistlib.dumps(d, fmt=plistlib.FMT_BINARY))
print('removed:', removed)
print('LaunchDaemons:', before, '->', len(ld))
PY

sync
umount "$M" && echo UNMOUNTED

#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/nolock.log) 2>&1

IMG=/root/fuxi/base.img
MNT=/root/fuxi/mnt/nolock
mkdir -p "$MNT"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$IMG" "$MNT"

python3 - "$MNT" <<'PY'
import plistlib, pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / 'private/var/mobile/Library/Preferences/com.apple.springboard.plist'
data = {}
if p.exists():
    try:
        data = plistlib.loads(p.read_bytes())
    except Exception as e:
        print('existing plist unreadable:', e)
data['SBAutoLockTime'] = 2147483647      # never auto-lock
data['SBDeviceLockBlocked'] = True       # block locking
data['SBDontLockOnSleep'] = True
data['SBShowNonDefaultSystemApps'] = True
p.parent.mkdir(parents=True, exist_ok=True)
p.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_BINARY))
print('springboard prefs written:', sorted(data))
print('path:', p)
PY

sync
umount "$MNT"
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -2
dd if="$IMG" of=/mnt/e/DSH-Fuxi/dump/iosroot-nolock.img bs=8M conv=sparse status=none
ls -lh /mnt/e/DSH-Fuxi/dump/iosroot-nolock.img
echo NOLOCK_IMAGE_OK

#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
RAW=/root/fuxi/inspect-root.raw
if [ ! -f "$RAW" ]; then
  simg2img "$P/ios16-root-v11-fixed.simg" "$RAW"
fi
M=/root/fuxi/mnt/inspect
mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,ro,force "$RAW" "$M"
echo "=== backboardd plist ==="
PL="$M/System/Library/LaunchDaemons/com.apple.backboardd.plist"
ls -l "$PL" 2>/dev/null || echo "MISSING"
if [ -f "$PL" ]; then
  python3 - "$PL" <<'PY'
import plistlib, sys
d = plistlib.load(open(sys.argv[1], 'rb'))
print('keys:', sorted(d.keys()))
print('Label:', d.get('Label'))
print('Program:', d.get('Program'), d.get('ProgramArguments'))
print('EnvironmentVariables:', d.get('EnvironmentVariables'))
PY
fi
echo "=== /redwood 是否已存在 ==="
ls -l "$M/redwood" 2>/dev/null || echo "(不存在，stage 会创建)"
sync
umount "$M" 2>/dev/null || umount -l "$M" 2>/dev/null || true

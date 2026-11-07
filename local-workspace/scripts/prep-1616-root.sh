#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-1616.img
M=/root/fuxi/mnt/root1616
mkdir -p "$M"
echo "=== fsck ==="
fsck.hfsplus -f -y "$IMG" 2>&1 | tail -1
echo "=== 挂载 ==="
mount -t hfsplus -o loop,rw,force "$IMG" "$M" 2>/dev/null || { echo MOUNT_FAILED; exit 1; }

echo "=== 诊断目录（mkiosroot 的 install -o 272 失败过）==="
install -d -m 0751 "$M/private/var/db/diagnostics" && chown 272:272 "$M/private/var/db/diagnostics"
install -d -m 0755 "$M/private/var/db/uuidtext" && chown 272:272 "$M/private/var/db/uuidtext"
install -d -m 0755 "$M/private/var/db/diagnostics/timesync" && chown 272:272 "$M/private/var/db/diagnostics/timesync"
for d in diagnostics uuidtext diagnostics/timesync; do
  : > "$M/private/var/db/$d/.migrated"; chown 272:272 "$M/private/var/db/$d/.migrated"; chmod 0644 "$M/private/var/db/$d/.migrated"
done
echo "=== keybag ==="
install -d -m 0700 -o 0 -g 0 "$M/private/var/keybags"
printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' \
  '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
  '<plist version="1.0"><dict><key>KeyBagKeys</key><data>U1dFRVQ=</data></dict></plist>' > "$M/private/var/keybags/systembag.kb"
chmod 0600 "$M/private/var/keybags/systembag.kb"
ls -l "$M/private/var/keybags/systembag.kb"

echo "=== sweet-root-tweaks ==="
cd /root/ios-fuxi
python3 tools/sweet-root-tweaks.py "$M" 2>&1 | tail -12

echo "=== 版本确认 ==="
grep -A1 ProductVersion "$M/System/Library/CoreServices/SystemVersion.plist" | head -2
sync
umount "$M" && echo UNMOUNTED

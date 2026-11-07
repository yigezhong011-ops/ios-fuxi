#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/root-iphonex.img
M=/root/fuxi/mnt/fix
mkdir -p "$M"
mount -o loop,rw,force "$IMG" "$M" 2>&1 || { echo "MOUNT_FAILED"; exit 1; }
echo "mounted"

# diagnostics dirs (the step that broke the build)
install -d -m 0751 "$M/private/var/db/diagnostics" && chown 272:272 "$M/private/var/db/diagnostics"
install -d -m 0755 "$M/private/var/db/uuidtext" && chown 272:272 "$M/private/var/db/uuidtext"
install -d -m 0755 "$M/private/var/db/diagnostics/timesync" && chown 272:272 "$M/private/var/db/diagnostics/timesync"
for d in diagnostics uuidtext diagnostics/timesync; do
  : > "$M/private/var/db/$d/.migrated"
  chown 272:272 "$M/private/var/db/$d/.migrated"
  chmod 0644 "$M/private/var/db/$d/.migrated"
done
echo "diagnostics dirs done"

# system keybag
install -d -m 0700 -o 0 -g 0 "$M/private/var/keybags"
printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' \
  '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
  '<plist version="1.0"><dict><key>KeyBagKeys</key><data>U1dFRVQ=</data></dict></plist>' > "$M/private/var/keybags/systembag.kb"
chmod 0600 "$M/private/var/keybags/systembag.kb"
echo "keybag written"

ls -l "$M/private/var/keybags/systembag.kb"
sync
umount "$M" && echo "unmounted"

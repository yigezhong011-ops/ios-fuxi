#!/bin/bash
# Write the UniXNU userdata image to the phone's userdata partition from TWRP over adb, streamed (no phone or PC scratch space),
# then read back and compare the manifest block and the image's SHA-256 over its length.
set -euo pipefail
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
WIN=$(wslpath -w "$IMG")
SIZE=$(stat -c %s "$IMG")
echo "image $SIZE bytes"
$ADB shell 'mount | grep -c " /data " || true'
# exec-in pipes stdin to the remote command byte-exactly.
cmd.exe /c "$(wslpath -w $ADB) exec-in \"dd of=/dev/block/by-name/userdata bs=4194304 conv=fsync\" < \"$WIN\""
$ADB shell sync
echo "### read-back"
$ADB shell "head -c 4096 /dev/block/by-name/userdata | head -c 8"; echo
REMOTE=$($ADB shell "head -c $SIZE /dev/block/by-name/userdata | sha256sum" | cut -d' ' -f1)
LOCAL=$(sha256sum "$IMG" | cut -d' ' -f1)
echo "remote $REMOTE"; echo "local  $LOCAL"
[ "$REMOTE" = "$LOCAL" ] && echo WRITE_OK || echo WRITE_MISMATCH

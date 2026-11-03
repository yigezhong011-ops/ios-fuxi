#!/bin/bash
# Compare the first <image size> bytes of the phone's userdata (TWRP, read-only) with the local userdata image.
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
SIZE=$(stat -c %s "$IMG")
$ADB shell sync
echo -n "magic: "; $ADB shell "head -c 8 /dev/block/by-name/userdata"; echo
REMOTE=$($ADB shell "head -c $SIZE /dev/block/by-name/userdata | sha256sum" | tr -d '\r' | cut -d' ' -f1)
LOCAL=$(sha256sum "$IMG" | cut -d' ' -f1)
echo "remote $REMOTE"; echo "local  $LOCAL"
[ "$REMOTE" = "$LOCAL" ] && echo WRITE_OK || echo WRITE_MISMATCH

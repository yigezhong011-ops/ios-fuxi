#!/bin/bash
# Write the UniXNU userdata image to the phone from TWRP in 256 MiB pieces: adb push (checked transfer) into TWRP's RAM /tmp,
# dd into place with seek, then compare that range's SHA-256 on the phone with the local piece. Stops at the first mismatch.
# The adb exec-in stream inserted ~1.6 MB near 2-4 MiB, so it is not used. Usage: push-userdata-chunks.sh [first-piece]
set -uo pipefail
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
P=/mnt/e/DSH-Fuxi/piece.bin   # on E: so the Windows adb can read it
PW=$(wslpath -w $P)
SIZE=$(stat -c %s "$IMG"); BS=$((256 * 1024 * 1024)); N=$(( (SIZE + BS - 1) / BS ))
START=${1:-0}
for i in $(seq $START $((N - 1))); do
  dd if="$IMG" of=$P bs=4M skip=$((i * 64)) count=64 status=none
  L=$(sha256sum $P | cut -c1-64); LEN=$(stat -c %s $P)
  $ADB push "$PW" /tmp/piece.bin >/dev/null || { echo "push failed at $i"; exit 1; }
  $ADB shell "dd if=/tmp/piece.bin of=/dev/block/by-name/userdata bs=4194304 seek=$((i * 64)) conv=notrunc,fsync 2>/dev/null; rm /tmp/piece.bin"
  R=$($ADB shell "dd if=/dev/block/by-name/userdata bs=4194304 skip=$((i * 64)) count=64 2>/dev/null | head -c $LEN | sha256sum" | tr -d '\r' | cut -c1-64)
  if [ "$L" = "$R" ]; then echo "piece $i/$((N - 1)) ok"; else echo "piece $i MISMATCH"; exit 1; fi
done
rm -f $P
echo ALL_PIECES_OK

#!/bin/bash
# Per-512 MiB SHA-256 of the phone's userdata vs the local image, to find where a streamed write went wrong.
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
SIZE=$(stat -c %s "$IMG"); BS=$((512*1024*1024)); N=$(( (SIZE + BS - 1) / BS ))
for i in $(seq 0 $((N-1))); do
  L=$(dd if="$IMG" bs=4M skip=$((i*128)) count=128 status=none | sha256sum | cut -c1-16)
  R=$($ADB shell "dd if=/dev/block/by-name/userdata bs=4194304 skip=$((i*128)) count=128 2>/dev/null | sha256sum" | tr -d '\r' | cut -c1-16)
  [ "$L" = "$R" ] && s=ok || s=DIFF
  echo "chunk $i ($((i*512)) MiB): $s"
  [ "$s" = DIFF ] && [ -z "${ALL:-}" ] && break
done

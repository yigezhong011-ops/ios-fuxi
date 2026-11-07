#!/bin/bash
# Read-only: over every saved USB log that got far enough, how often the touch service was taken by the kernel driver and how often by the dext.
cd /mnt/e/DSH-Fuxi/logs || exit 1
for f in com3-*.log; do
  a=$(grep -a -c 'open by IOHIDEventDriver' "$f"); b=$(grep -a -c 'AppleUserHIDEventDriver-' "$f")
  [ "$a" = 0 ] && [ "$b" = 0 ] && continue
  echo "$f kext=$a dext=$b"
done > /tmp/touch-rate.txt
wc -l < /tmp/touch-rate.txt
echo "dext boots:"; grep -v 'dext=0' /tmp/touch-rate.txt | cut -c1-70
echo "kext boots: $(grep -c 'dext=0' /tmp/touch-rate.txt)"

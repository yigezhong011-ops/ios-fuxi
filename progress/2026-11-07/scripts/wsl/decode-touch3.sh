#!/bin/bash
# decode-shot.py needs the SCREENSHOT reply line next to the frame; rebuild those five and decode.
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs
S=t50-auto-touch3-231134
meta=(
  "SXNU1R 762a744a4fc9d591 00000001 SCREENSHOT OK state=ready width=360 height=800 bytes=864000 encoded=17492 crc32=9b643a12 frame=1 encoding=rle"
  "SXNU1R 762a744a4fc9d591 0000005e SCREENSHOT OK state=ready width=360 height=800 bytes=864000 encoded=31920 crc32=69debcce frame=94 encoding=rle"
  "SXNU1R 762a744a4fc9d591 00000106 SCREENSHOT OK state=ready width=360 height=800 bytes=864000 encoded=89736 crc32=41293f47 frame=262 encoding=rle"
  "SXNU1R 762a744a4fc9d591 000002db SCREENSHOT OK state=ready width=360 height=800 bytes=864000 encoded=183212 crc32=09e7e35d frame=731 encoding=rle"
  "SXNU1R 762a744a4fc9d591 00000697 SCREENSHOT OK state=ready width=360 height=800 bytes=864000 encoded=183212 crc32=09e7e35d frame=1687 encoding=rle"
)
for i in 1 2 3 4 5; do
  printf '%s\n' "${meta[$((i-1))]}" > "$L/shot-$S-$i.txt"
done
for i in 1 2 3 4 5; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/decode-shot.py "$L/shot-$S-$i" || true
done
ls -l "$L"/shot-$S-*.png 2>/dev/null

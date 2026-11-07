#!/bin/bash
# How much the boot image's kernel section (gzip of loader + payload FAT) shrinks when the FAT's free clusters are zeroed:
# deleted files leave their old bytes in free clusters, which gzip has to carry. Works on copies only.
set -euo pipefail
W=/root/fuxi/room
rm -rf "$W"; mkdir -p "$W"
cp /root/fuxi/t32/vol.img "$W/vol.img"
free=$(minfo -i "$W/vol.img" :: | awk '/free clusters=/{split($0,a,"="); print a[2]}')
bytes=$(( (free - 8) * 2048 ))
echo "free clusters $free -> zero file of $bytes bytes"
head -c "$bytes" /dev/zero > "$W/zero.bin"
mcopy -i "$W/vol.img" "$W/zero.bin" ::/ZERO.BIN
mdel -i "$W/vol.img" ::/ZERO.BIN
echo "gzip -9 of the payload FAT, before and after:"
gzip -9 -c /root/fuxi/t32/vol.img | wc -c
gzip -9 -c "$W/vol.img" | wc -c

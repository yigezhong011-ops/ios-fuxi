#!/bin/bash
# First bytes where the phone's userdata and the local image differ (first 2 MiB).
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
head -c 2097152 "$IMG" > /root/fuxi/l.bin
$ADB exec-out "head -c 2097152 /dev/block/by-name/userdata" > /root/fuxi/r.bin
ls -l /root/fuxi/l.bin /root/fuxi/r.bin
cmp /root/fuxi/l.bin /root/fuxi/r.bin | head -3
cmp -l /root/fuxi/l.bin /root/fuxi/r.bin | wc -l
O=$(cmp /root/fuxi/l.bin /root/fuxi/r.bin | grep -o 'byte [0-9]*' | cut -d' ' -f2)
[ -n "$O" ] && { S=$((O-17)); [ $S -lt 0 ] && S=0; echo local; xxd -s $S -l 48 /root/fuxi/l.bin; echo remote; xxd -s $S -l 48 /root/fuxi/r.bin; }

#!/bin/bash
# Byte-level diff of one 4 MiB block (phone vs local image). Usage: diff-block.sh <block>
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
B=$1
dd if="$IMG" bs=4M skip=$B count=1 status=none > /root/fuxi/lb.bin
$ADB exec-out "dd if=/dev/block/by-name/userdata bs=4194304 skip=$B count=1 2>/dev/null" > /root/fuxi/rb.bin
ls -l /root/fuxi/lb.bin /root/fuxi/rb.bin | awk '{print $5}'
echo "differing bytes: $(cmp -l /root/fuxi/lb.bin /root/fuxi/rb.bin | wc -l)"
O=$(cmp /root/fuxi/lb.bin /root/fuxi/rb.bin | grep -o 'byte [0-9]*' | cut -d' ' -f2)
echo "first at byte $O"
S=$(( O > 33 ? O - 33 : 0 ))
echo local; xxd -s $S -l 64 /root/fuxi/lb.bin; echo remote; xxd -s $S -l 64 /root/fuxi/rb.bin
echo "remote all-zero? $(tr -d '\0' < /root/fuxi/rb.bin | wc -c) nonzero bytes"

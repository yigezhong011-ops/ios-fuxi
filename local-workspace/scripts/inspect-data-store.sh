#!/bin/bash
# Look at the head of the persistent Data store window (log: lba=36bc37a absolute; userdata starts at 0x2f7840),
# without writing. Usage: inspect-data-store.sh
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
START=$(( 0x36bc37a - 0x2f7840 ))
echo "store window starts at userdata block $START ($(( START * 4096 / 1073741824 )) GiB)"
$ADB exec-out "dd if=/dev/block/by-name/userdata bs=4096 skip=$START count=4 2>/dev/null" > /root/fuxi/store-head.bin
xxd -l 96 /root/fuxi/store-head.bin
echo "nonzero bytes in first 16 KiB: $(tr -d '\0' < /root/fuxi/store-head.bin | wc -c)"
echo "--- one block before the window (should be outside the root image)"
$ADB exec-out "dd if=/dev/block/by-name/userdata bs=4096 skip=$((START - 1)) count=1 2>/dev/null" | xxd -l 32

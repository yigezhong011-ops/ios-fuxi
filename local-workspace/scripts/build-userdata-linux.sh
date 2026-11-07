#!/bin/bash
# Build the UniXNU userdata image for fuxi on Linux: the OS and SystemOS APFS
# windows the kernel expects at the start of the userdata partition.
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/userdata-build.log
: > "$LOG"
echo "== 开始（会从 Apple CDN 取 OS/SystemOS，比较大）"
./unixnu build userdata -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "USERDATA_EXIT=$code"
tail -25 "$LOG"
echo
echo "=== 产物 ==="
find out/fuxi -name '*userdata*' -o -name '*.img' 2>/dev/null | head -10
ls -lh out/fuxi/userdata/ 2>/dev/null | head -6

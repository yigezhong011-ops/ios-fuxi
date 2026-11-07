#!/bin/bash
# Read-only: does the kernel log show clients refused for want of a slot? Prints the client table and failure counters from the wall17 boot.
E=/mnt/e/DSH-Fuxi
D=$(python3 -I $E/unixnu-build/fuxi/scripts/read-sheng-log.py --decode $E/logs/carve-wall17/log.bin --out /root/fuxi/hang/wall17 2>&1 | tail -1 | cut -d: -f1)
echo "log $D"; sed -n 1p "$D/latest.txt" | cut -c1-80
grep -a -E '^\[(gpu clients|gpu windows|gpu mount|gpu)\]|mount_fail|mount fail' "$D/latest.txt" | cut -c1-900 | head -10
echo '== where the driver reports it'
grep -rn -E 'native_adreno_mount_fail|native_adreno_client_log' $E/unixnu-build/unixnu/drivers/Adreno740/*.cpp $E/unixnu-build/fuxi --include=* 2>/dev/null | grep -v -E 'NativeAdrenoPublish.cpp:(2[0-9][0-9])' | cut -c1-190 | head -10
grep -n -E 'struct NativeAdrenoClientRecord' -A10 $E/unixnu-build/unixnu/drivers/Adreno740/*.cpp $E/unixnu-build/unixnu/drivers/Adreno740/*.h 2>/dev/null | cut -c1-150 | head -16

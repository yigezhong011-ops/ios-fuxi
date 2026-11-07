#!/bin/bash
set -uo pipefail
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
echo "=== 1. 移动到 /data/fuxi/iosroot.img ==="
"$ADB" shell 'su -c "mv -f /data/local/tmp/iosroot-new.img /data/fuxi/iosroot.img && ls -l /data/fuxi/iosroot.img"' 2>&1
echo
echo "=== 2. 重新算 extents ==="
"$ADB" shell 'su -c "/data/local/tmp/fiemap_bytes /data/fuxi/iosroot.img > /data/local/tmp/ext-new.json && head -c 300 /data/local/tmp/ext-new.json"' 2>&1
echo
echo "=== 3. 拉回本地 ==="
"$ADB" pull /data/local/tmp/ext-new.json /mnt/e/DSH-Fuxi/dump/ext-new.json 2>&1 | tail -1
ls -l /mnt/e/DSH-Fuxi/dump/ext-new.json

#!/bin/bash
set -uo pipefail
echo "=== E: 上的 iOS 材料 ==="
ls -lh /mnt/e/DSH-Fuxi/ 2>/dev/null | head -12
echo
echo "=== d22ap IPSW / dmg ==="
find /mnt/e/DSH-Fuxi -maxdepth 2 -iname '*.ipsw' -o -maxdepth 2 -iname '*d22ap*' 2>/dev/null | head -5
echo
echo "=== 手机上的 root 镜像 ==="
/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe shell 'ls -l /data/fuxi/' 2>&1 | head -6

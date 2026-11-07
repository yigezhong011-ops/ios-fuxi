#!/bin/bash
set -uo pipefail
echo "=== 谁写了 ext-bytes.json ==="
grep -rln 'ext-bytes' /mnt/e/DSH-Fuxi/dump/wsl/ /root/ios-fuxi/ 2>/dev/null | head -8
echo
echo "=== 手机上的 fiemap 工具 ==="
/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe shell 'su -c "ls -l /data/local/tmp/*ext* /data/local/tmp/fiemap* /data/fuxi/*ext* 2>/dev/null"' 2>&1 | head -8
echo
echo "=== E: 上现有 json ==="
find /mnt/e/DSH-Fuxi -maxdepth 2 -name '*.json' 2>/dev/null | head -5

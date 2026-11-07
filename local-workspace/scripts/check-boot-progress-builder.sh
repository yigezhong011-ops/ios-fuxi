#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== 设备仓库里的 boot-progress 构建脚本 ==="
ls "$D/scripts" | grep -i 'boot.progress\|bootprogress'
echo
F=$(ls "$D"/scripts/*boot-progress*.py 2>/dev/null | head -1)
if [ -n "$F" ]; then
  echo "--- $F 里的 defines ---"
  grep -n 'XNU_BOOT_PROGRESS\|-D' "$F" | head -12 | cut -c1-170
fi

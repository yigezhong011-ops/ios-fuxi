#!/bin/bash
set -uo pipefail
echo "=== 找 extents 工具/脚本 ==="
ls -l /root/ios-fuxi/tools/*extent* /root/ios-fuxi/tools/*fiemap* 2>/dev/null
grep -rln 'FIEMAP\|fiemap' /root/ios-fuxi/tools/ 2>/dev/null | head -5
echo
echo "=== step24 里怎么取 extents ==="
grep -n -B3 -A8 'extent' /mnt/e/DSH-Fuxi/dump/wsl/step24-build-diag2.sh | head -30

#!/bin/bash
set -euo pipefail
DEV=/root/UniXNU-fuxi
mkdir -p "$DEV/scripts"
cp /mnt/e/DSH-Fuxi/unixnu/check-fuxi.py "$DEV/scripts/check-fuxi.py"
chmod +x "$DEV/scripts/check-fuxi.py"
ls -l "$DEV/scripts/"
echo "=== 重新跑 firmware 构建 ==="
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D "$DEV" > /root/unixnu-fw2.log 2>&1 || true
echo "=== 结果 ==="
tail -25 /root/unixnu-fw2.log
echo "=== 产出的 FD ==="
find /root/uefi-fuxi -name '*.fd' -newer /root/uefi-fuxi/README.md 2>/dev/null | head -5

#!/bin/bash
set -uo pipefail
echo "=== hakios-uefi 的 apply.sh ==="
head -25 /root/hakios-uefi/apply.sh 2>/dev/null || echo "（未克隆）"
echo
echo "=== sm7325 设备仓库的 uefi/apply.sh ==="
cat /root/hakios-sm7325/uefi/apply.sh 2>/dev/null | head -25
echo
echo "=== sm7325 的 uefi/files 内容 ==="
find /root/hakios-sm7325/uefi/files -maxdepth 3 -type d 2>/dev/null | head -12

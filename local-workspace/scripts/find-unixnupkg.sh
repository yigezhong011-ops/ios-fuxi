#!/bin/bash
set -uo pipefail
echo "=== 找 AdvancedLogViewLib.inf ==="
find /root/build -name 'AdvancedLogViewLib.inf' 2>/dev/null | head -5
echo
echo "=== UniXNUPkg 目录在哪 ==="
find /root/build -maxdepth 6 -type d -name 'UniXNUPkg' 2>/dev/null | head -8
echo
echo "=== 固件树根目录 ==="
ls /root/build/uefi-fuxi | head -20

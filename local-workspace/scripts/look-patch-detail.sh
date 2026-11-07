#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== 补丁涉及的文件 ==="
grep -E '^diff --git|^--- a/|^\+\+\+ b/' uefi/mu-silicium.patch | head -20
echo
echo "=== BootManagerLib 部分（前 80 行）==="
awk '/BootManagerLib/,0' uefi/mu-silicium.patch | head -80
echo
echo "=== uefi/files 里的新文件 ==="
find uefi/files -maxdepth 3 -type d | head -10
ls uefi/files/Silicon/*/Library/BootManagerLib/ 2>/dev/null || find uefi/files -name 'XnuLoader*' | head -5

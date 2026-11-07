#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== uefi/README.md ==="
cat uefi/README.md
echo
echo "=== uefi/apply.sh ==="
cat uefi/apply.sh
echo
echo "=== 补丁里改了哪些文件 ==="
grep -E '^(---|\+\+\+) ' uefi/mu-silicium.patch | head -20

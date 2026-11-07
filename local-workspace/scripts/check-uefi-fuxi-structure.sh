#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
echo "=== uefi-fuxi 顶层 ==="
ls "$U" | head -15
echo
echo "=== fuxiPkg 内容 ==="
ls "$U/Platforms/Xiaomi/fuxiPkg" | head -15
echo
echo "=== Resources/DTBs ==="
ls "$U/Resources/DTBs" 2>/dev/null | head -8
echo
echo "=== Binaries ==="
ls "$U/Binaries" 2>/dev/null | head -8
echo
echo "=== 与 HakiOS 的 BASE 是否同一上游 ==="
cat /root/hakios-uefi/BASE 2>/dev/null
git -C "$U" log --oneline -1 2>/dev/null | cut -c1-90

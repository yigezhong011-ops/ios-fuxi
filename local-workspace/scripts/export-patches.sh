#!/bin/bash
# Export the firmware change as a reviewable patch, plus the log-kit integration diff.
set -uo pipefail
U=/root/build/uefi-fuxi
OUT=/root/fuxi/patches
mkdir -p "$OUT"
rm -f "$OUT"/*.patch

echo "=== uefi-fuxi 的改动 ==="
git -C "$U" status --short -- Platforms/Xiaomi/fuxiPkg/fuxi.dsc Platforms/Xiaomi/fuxiPkg/Include/DXE.inc
git -C "$U" diff -- Platforms/Xiaomi/fuxiPkg/fuxi.dsc Platforms/Xiaomi/fuxiPkg/Include/DXE.inc > "$OUT/0001-fuxi-usb-power.patch"
wc -l "$OUT/0001-fuxi-usb-power.patch"
cat "$OUT/0001-fuxi-usb-power.patch"

echo
echo "=== UniXNUPkg（日志套件集成）的改动 ==="
T=/root/build/unixnu
git -C "$T" status --short -- package/UniXNUPkg 2>/dev/null | head -10
git -C "$T" diff -- package/UniXNUPkg > "$OUT/0002-unixnupkg-log-kit.patch" 2>/dev/null
wc -l "$OUT/0002-unixnupkg-log-kit.patch"
head -40 "$OUT/0002-unixnupkg-log-kit.patch"

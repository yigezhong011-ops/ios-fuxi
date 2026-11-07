#!/bin/bash
# Read-only: where AdvancedLogViewLib should come from, and how the fuxi dsc in use differs from upstream.
W=/root/fuxi/fw; E=/mnt/e/DSH-Fuxi/unixnu-build
find "$W" -name 'AdvancedLogViewLib*' -not -path '*/Build/*' 2>/dev/null | head -5
ls "$W/unixnu/package/UniXNUPkg" "$W/unixnu/package/UniXNUPkg/Library" 2>/dev/null | head -20
sed -n 158,163p "$W/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc" | tr -d '\r'
git -C "$E/uefi-fuxi" log -2 --format='%h %ad %s' --date=short -- Platforms/Xiaomi/fuxiPkg/fuxi.dsc | cut -c1-90
git -C "$E/uefi-fuxi" grep -n 'AdvancedLogView' | cut -c1-120 | head -6
git -C "$E/unixnu" log --all -1 --format='%h %ad %s' --date=short -- package/UniXNUPkg/Library/AdvancedLogViewLib 2>/dev/null | cut -c1-90
git -C "$E/unixnu" log -1 --format='local unixnu %h %ad' --date=short
git -C "$E/uefi-fuxi" log -1 --format='local uefi-fuxi %h %ad' --date=short
grep -n -i -E 'uefi|firmware' "$W/fuxi/device.toml" 2>/dev/null | cut -c1-120 | head -10
grep -rln 'AdvancedLogView' "$W/fuxi" /root/fuxi/ref-qcomxnuusbdebug 2>/dev/null | head -5
sed -n 1,40p "$E/uefi-fuxi/scripts/build-firmware.sh" | tr -d '\r' | cut -c1-130

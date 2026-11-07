#!/bin/bash
# Baseline firmware build, second try, WSL copy only: AdvancedLogViewLib is in no public tree, and only the two log drivers use it, so they leave this copy.
# The FD will therefore not match the booted one byte for byte. Writes no partition.
set -uo pipefail
W=/root/fuxi/fw; D=$W/uefi-fuxi/Platforms/Xiaomi/fuxiPkg
sed -i '/AdvancedLogViewLib|UniXNUPkg/d; /FuxiUfsLogDxe\/FuxiUfsLogDxe.inf/d; /FuxiUefiLogDxe\/FuxiUefiLogDxe.inf/d' "$D/fuxi.dsc"
sed -i '/FuxiUfsLogDxe\/FuxiUfsLogDxe.inf/d; /FuxiUefiLogDxe\/FuxiUefiLogDxe.inf/d' "$D/Include/DXE.inc"
grep -n -E 'AdvancedLogView|Fuxi(Ufs|Uefi)LogDxe|FUXI_USB_POWER' "$D/fuxi.dsc" "$D/Include/DXE.inc" | cut -c40-130
cd "$W/unixnu" || exit 1
echo "build start $(date +%T)"
python3 unixnu build firmware -D "$W/fuxi" --uefi "$W/uefi-fuxi" --target DEBUG -j 12 > "$W/build-base.log" 2>&1
echo "build exit $? $(date +%T)"
grep -n -E 'error|Error|not found' "$W/build-base.log" | head -12 | cut -c1-170
tail -8 "$W/build-base.log" | cut -c1-150
find "$W/uefi-fuxi/Build" "$W/unixnu/out" -name '*.fd' -printf '%s %p\n' 2>/dev/null | head -6 | while read -r s p; do echo "$s $p $(sha256sum "$p" | cut -c1-16)"; done

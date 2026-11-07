#!/bin/bash
# Firmware with FuxiUsbStartDxe, in the WSL copy only. Writes no partition. Leaves the FD at /root/fuxi/fw/usbstart.fd.
set -uo pipefail
W=/root/fuxi/fw; D=$W/uefi-fuxi/Platforms/Xiaomi/fuxiPkg; M=$D/Drivers/FuxiUsbStartDxe
mkdir -p "$M"
for f in FuxiUsbStartDxe.c FuxiUsbStartDxe.inf; do tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/FuxiUsbStartDxe/$f > "$M/$f"; done
grep -q FuxiUsbStartDxe "$D/fuxi.dsc" || sed -i 's#^\(\s*\)FatPkg/EnhancedFatDxe/Fat.inf#\1fuxiPkg/Drivers/FuxiUsbStartDxe/FuxiUsbStartDxe.inf\n&#' "$D/fuxi.dsc"
grep -q FuxiUsbStartDxe "$D/Include/DXE.inc" || sed -i 's#^\(\s*\)INF Binaries/nuwa/QcomPkg/Drivers/UCDxe/UCDxe.inf#&\n\1INF fuxiPkg/Drivers/FuxiUsbStartDxe/FuxiUsbStartDxe.inf#' "$D/Include/DXE.inc"
git -C "$W/uefi-fuxi" checkout -- Platforms/Xiaomi/fuxiPkg/fuxi.dec
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/FuxiUsbStartDxe/FuxiUsbStart.dec > "$M/FuxiUsbStart.dec"
grep -n FuxiUsbStartDxe "$D/fuxi.dsc" "$D/Include/DXE.inc" | cut -c40-120
cd "$W/unixnu" || exit 1
echo "build start $(date +%T)"
python3 unixnu build firmware -D "$W/fuxi" --uefi "$W/uefi-fuxi" --target DEBUG -j 12 > "$W/build-usbstart.log" 2>&1
R=$?; echo "build exit $R $(date +%T)"
grep -n -E ': error|error [0-9A-F]{4,}|Failed' "$W/build-usbstart.log" | head -10 | cut -c1-170
[ "$R" = 0 ] || exit 1
FD=$W/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
stat -c '%s %y' "$FD" | cut -c1-40; sha256sum "$FD" | cut -c1-16
cp "$FD" "$W/usbstart.fd"
strings -a -e l "$FD" | grep -c FuxiUsbStart
find "$W/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB" -name 'FuxiUsbStartDxe.efi' | head -2
echo '== how the FD gets into boot images'
find "$W/unixnu/out" -maxdepth 3 -name '*.bin' -newer "$FD" 2>/dev/null | head -4
grep -n -E 'BootShim|\.fd|loader|FD_' "$W/uefi-fuxi/scripts/bootimage.py" | cut -c1-120 | head -12

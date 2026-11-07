#!/bin/bash
# Baseline firmware build in /root/fuxi/fw, on a copy: the E: trees stay untouched. FUXI_USB_POWER off in the copy, so this should match what we boot today. Writes no partition.
set -uo pipefail
E=/mnt/e/DSH-Fuxi/unixnu-build; W=/root/fuxi/fw
mkdir -p "$W"
for t in unixnu fuxi uefi-fuxi; do
  [ -d "$W/$t" ] || { echo "copy $t $(date +%T)"; cp -a "$E/$t" "$W/$t"; }
done
[ -e "$W/UniXNU" ] || ln -s "$W/unixnu" "$W/UniXNU"
[ -e "$W/unixnu-fuxi" ] || ln -s "$W/fuxi" "$W/unixnu-fuxi"
cd "$W/uefi-fuxi" || exit 1
sed -i 's/^\(\s*FUXI_USB_POWER\s*=\s*\)1/\10/' Platforms/Xiaomi/fuxiPkg/fuxi.dsc
sed -i '/NicobarPkg\/Drivers\/UsbPwrEnablerDxe\/UsbPwrEnablerDxe.inf/{/^  NicobarPkg/d}' Platforms/Xiaomi/fuxiPkg/fuxi.dsc
git status -sb | head -6; git diff --stat | tail -3
cd "$W/unixnu" || exit 1
git log -1 --format='unixnu %h %ad %s' --date=short | cut -c1-90
echo "build start $(date +%T)"
python3 unixnu build firmware -D "$W/fuxi" --uefi "$W/uefi-fuxi" --target DEBUG -j 12 > "$W/build-base.log" 2>&1
echo "build exit $? $(date +%T)"
tail -25 "$W/build-base.log" | cut -c1-170
find "$W/uefi-fuxi/Build" -name 'SILICIUM_UEFI.fd' -printf '%s %p\n' 2>/dev/null | while read -r s p; do echo "$s $p $(sha256sum "$p" | cut -c1-16)"; done
echo 'current image FD: c421e9eb6cc2cd11 3145728'

#!/bin/bash
# Publish the USB firmware fix (patch + write-up) in the progress repository so it can be
# handed to someone else by URL.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-03
E=/mnt/e/DSH-Fuxi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
mkdir -p "$DEST/firmware-usb-power" "$DEST/scripts/wsl"
cp "$E/PATCH-fuxi-usb-power/README.md" "$DEST/firmware-usb-power/README.md"
cp "$E/PATCH-fuxi-usb-power/0001-fuxi-usb-power.patch" "$DEST/firmware-usb-power/"
cp "$E/PATCH-fuxi-usb-power/0002-unixnupkg-log-kit.patch" "$DEST/firmware-usb-power/" 2>/dev/null || true
for n in enable-usb-power.py add-usb-component.py build-firmware-native.sh pack-with-fd.sh \
         build-usb-image.sh export-patches.sh complete-logkit-dec.py; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done

echo "== secret scan"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|UNIQUE_CHIP_ID_REDACTED|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "secret-like content found: not committing"; exit 1
fi
echo clean
git add "$DEST"
git status --short | head -20
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "firmware: power the USB controller so the kernel console appears

The fuxi firmware loads only the vendor stack UFS needs (FUXI_UFS_STACK = 1, documented
as without Display/USB/charger) and UsbPwrEnablerDxe was only referenced by the ginkgo and
willow FDFs, so the kernel's QcomXnuUsbDebug never sees a powered controller and the host
never enumerates the CDC ACM console. Adds UsbPwrEnablerDxe behind FUXI_USB_POWER in
fuxi.dsc and DXE.inc. The firmware builds (SILICIUM_UEFI.fd 3145728 bytes, UsbPwrEnablerDxe
and UsbPwrCtrlDxe present in FV/Ffs). Records the build traps: /mnt/c-style 9p mounts break
git index.lock, dirty out/feeds blocks fetch, DEBUG needs the log kit's AdvancedLogViewLib."
  git push -q origin main
  git log --oneline -1
fi

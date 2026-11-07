#!/bin/bash
# Read-only: what UsbPwrEnablerDxe needs and does, which USB drivers the fuxi firmware loads, and whether the driver the kernel uses saw VBUS on a normal boot.
set -u
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi; D=$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe
cat "$D/UsbPwrEnablerDxe.inf" | tr -d '\r' | head -30
echo '== depex'; xxd "$D/UsbPwrEnablerDxe.depex" | head -6
echo '== strings'; strings -a -n 6 "$D/UsbPwrEnablerDxe.efi" | head -40 | cut -c1-110
echo '== guids in efi'; python3 -I - "$D/UsbPwrEnablerDxe.depex" <<'PY'
import sys, uuid
d = open(sys.argv[1], 'rb').read()
at = 0
while at < len(d):
    op = d[at]; at += 1
    if op == 2:
        print('PUSH', uuid.UUID(bytes_le=d[at:at + 16])); at += 16
    else:
        print('op', op)
PY
echo '== diff'; git -C "$U" diff --stat | tail -4
echo '== USB in fuxi'; grep -n -i -E 'usb|FUXI_VENDOR_HW|FUXI_UFS_STACK|!if|!endif' "$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" | tr -d '\r' | cut -c1-110 | head -60
grep -n -E 'FUXI_VENDOR_HW|FUXI_UFS_STACK' "$U/Platforms/Xiaomi/fuxiPkg/fuxi.dsc" | tr -d '\r' | cut -c1-110 | head
ls "$U/Silicon/Qualcomm/NicobarPkg/Drivers" 2>/dev/null | grep -i usb | head; find "$U/Binaries" "$U/Silicon" -maxdepth 6 -type d -iname '*UsbPwr*' 2>/dev/null | cut -c30- | head -12
find "$U/Binaries" -maxdepth 5 -type d -iname 'Usb*' 2>/dev/null | cut -c30- | head -20
echo '== BootProgress/USB debug'; Q=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/drivers/QcomXnuUsbDebug; grep -n -i -E 'vbus|acquire_' "$Q/kernel/QcomXnuUsbDebug.c" | cut -c1-130 | head -20
grep -n -i -E 'vbus|repeater|phy|qualif' "$Q/soc/QcomUsbQualify.c" | cut -c1-130 | head -30

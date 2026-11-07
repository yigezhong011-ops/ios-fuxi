#!/bin/bash
# Read-only: which nuwa binaries carry the protocol GUIDs UsbPwrEnablerDxe uses, and what the nuwa USB drivers say they do.
set -u
N=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers; U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
python3 -I - "$N" "$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe" <<'PY'
import glob, os, sys, uuid
N, E = sys.argv[1:3]
depex = open(E + '/UsbPwrEnablerDxe.depex', 'rb').read()[1:17]
used = open(E + '/UsbPwrEnablerDxe.efi', 'rb').read()[0x2000:0x2010]
usbfn = uuid.UUID('32d2963a-fe5d-4f30-b633-6e5dc55803cc').bytes_le  # EFI_USBFN_IO_PROTOCOL
print('depex', uuid.UUID(bytes_le=depex), 'located', uuid.UUID(bytes_le=used))
for name, g in (('depex', depex), ('located', used), ('usbfn_io', usbfn)):
    hits = []
    for f in glob.glob(N + '/**/*', recursive=True):
        if os.path.isfile(f):
            d = open(f, 'rb').read()
            if g in d:
                hits.append(f[len(N) + 1:])
    print(name, 'found in', hits[:10])
PY
ls "$N/UsbInitDxe" "$N/UsbConfigDxe" "$N/UsbPwrCtrlDxe" "$N/UsbfnDwc3Dxe" | head -24
for d in UsbInitDxe UsbConfigDxe UsbfnDwc3Dxe UsbPwrCtrlDxe; do
  f=$(ls "$N/$d"/*.efi 2>/dev/null | head -1); [ -n "$f" ] || { echo "== $d: no .efi"; continue; }
  echo "== $d $(stat -c%s "$f")"
  strings -a -n 7 "$f" | grep -i -E 'clock|gdsc|phy|repeater|vbus|exit|ExitBoot|cold|start|device mode|peripheral|host|init' | cut -c1-90 | sort -u | head -24
done
echo '== doc: firmware USB in fuxi'; grep -rn -i -E 'UsbfnDwc3|UsbInitDxe|UsbConfigDxe|StartController' "$U/Platforms/Xiaomi/fuxiPkg" 2>/dev/null | tr -d '\r' | cut -c50-170 | head -10

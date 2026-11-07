#!/bin/bash
# Read-only: the end of UsbInitDxe's entry point (protocol install) and the methods it publishes. Offsets are .text offsets: add 0x1000 for image addresses.
D=/root/fuxi/usbinit.dis; G=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers/UsbInitDxe/UsbInitDxe.efi
cut -f2- "$D" | head -0
echo '== adrp/add pairs to .data with blr nearby'
grep -n -E 'adrp\s+x[0-9]+, 0x5000' "$D" | wc -l
grep -n -E 'blr' "$D" | cut -c1-60
echo '== data pointer table after GUIDs'
python3 -I - "$G" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
for o in range(0x60c8, 0x6220, 8):
    v = struct.unpack_from('<Q', d, o)[0]
    if v:
        print(hex(o), hex(v))
PY
sed -n 106,116p /root/fuxi/fw/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc | tr -d '\r' | cut -c1-80
L=$(grep -n 'UsbInitDriverEntryPoint' "$D" | head -1 | cut -d: -f1)
echo '== strings offsets: UsbInitDriverEntryPoint at 0x40d1 file. who loads it'
grep -n -E 'add\s+x[0-9]+, x[0-9]+, #0xd1$|#0xd1\b' "$D" | cut -c1-60 | head -5

#!/bin/bash
# Read-only: who holds the UsbInit protocol GUID among the nuwa binaries, the config method's handling of mode, and the shape of its calls.
N=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers
python3 -I - "$N" <<'PY'
import glob, os, sys, uuid
N = sys.argv[1]
g = uuid.UUID('2da15ac7-4909-4c4c-b8c3-a742195ea46e').bytes_le
for f in glob.glob(N + '/**/*', recursive=True):
    if os.path.isfile(f) and g in open(f, 'rb').read():
        print('holds UsbInit GUID:', f[len(N) + 1:])
PY
strings -a -n 6 "$N/UsbConfigDxe/UsbConfigDxe.efi" | grep -E 'Mode|mode|ConfigUsb|Device|Host|Core|core|Vbus|Clock' | cut -c1-70 | sort -u | head -26
for d in UsbDeviceDxe UsbfnDwc3Dxe; do echo "== $d"; strings -a -n 6 "$N/$d/$d.efi" | grep -E 'UsbInit|StartController|[Mm]ode|Enumerate|Start|Core' | cut -c1-70 | sort -u | head -14; done

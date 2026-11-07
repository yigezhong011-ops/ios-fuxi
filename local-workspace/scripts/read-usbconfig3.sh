#!/bin/bash
# Read-only: the mode switch in UsbConfigDxe's UsbStartController.
N=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers/UsbConfigDxe/UsbConfigDxe.efi; D=/root/fuxi/usbconfig.dis
python3 -I - "$N" "$D" <<'PY'
import re, struct, sys
d = open(sys.argv[1], 'rb').read(); out = open(sys.argv[2]).read().splitlines()
pe = struct.unpack_from('<I', d, 0x3c)[0]; opt = struct.unpack_from('<H', d, pe + 20)[0]
rp = struct.unpack_from('<I', d, pe + 24 + opt + 20)[0]
for needle in (b'UsbStartController: Error - Core', b'Error - ModeType is USB_INVALID_MODE'):
    s = d.find(needle); fmt = d.rfind(b'\0', 0, s) + 1; t = fmt - rp
    for i, l in enumerate(out):
        c = re.sub(r'\s*//.*|\s*<.*>', '', l)
        if re.search(r'add\s+x\d+, x\d+, #0x%x$' % (t & 0xfff), c) and hex(t & ~0xfff) in ''.join(out[max(0, i-2):i]):
            print('==', needle.decode(), hex(t), 'at line', i)
            for b in out[max(0, i - 60):i + 8]:
                b = re.sub(r'\s*<.*>|\s*//.*', '', b)[4:58]
                if re.search(r'cmp|subs|tbnz|tbz|blr|\bbl\b|cbz|cbnz|b\.|mov\s+w\d+, #|ldr\s+x8, \[x\d+, #0x', b):
                    print(b)
            break
PY

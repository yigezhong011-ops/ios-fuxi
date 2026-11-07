#!/bin/bash
# Read-only: the protocol UsbInitDxe installs and the shape of its calls.
set -u
N=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers/UsbInitDxe
tr -d '\r' < "$N/UsbInitDxe.inf" | head -24
xxd "$N/UsbInitDxe.depex" | head -4
python3 -I - "$N/UsbInitDxe.efi" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
pe = struct.unpack_from('<I', d, 0x3c)[0]
n = struct.unpack_from('<H', d, pe + 6)[0]; opt = struct.unpack_from('<H', d, pe + 20)[0]
print('entry', hex(struct.unpack_from('<I', d, pe + 40)[0]), 'machine', hex(struct.unpack_from('<H', d, pe + 4)[0]))
at = pe + 24 + opt
for i in range(n):
    name = d[at:at + 8].rstrip(b'\0').decode(); vs, va, rs, rp = struct.unpack_from('<IIII', d, at + 8); at += 40
    print(name, hex(va), hex(vs), hex(rp), hex(rs))
    if name == '.text':
        open('/tmp/ui.text', 'wb').write(d[rp:rp + rs]); open('/tmp/ui.va', 'w').write(hex(va))
    if name == '.data':
        open('/tmp/ui.data', 'wb').write(d[rp:rp + rs]); open('/tmp/ui.dva', 'w').write(hex(va))
PY
llvm-objcopy -I binary -O elf64-littleaarch64 -B aarch64 --rename-section .data=.text,code /tmp/ui.text /tmp/ui.o
llvm-objdump -d --no-show-raw-insn --adjust-vma=$(cat /tmp/ui.va) /tmp/ui.o > /root/fuxi/usbinit.dis; wc -l /root/fuxi/usbinit.dis
strings -a -n 5 -t x "$N/UsbInitDxe.efi" | grep -E 'UsbInit|Controller|Protocol|Core|mode|Mode' | cut -c1-90 | head -30
xxd /tmp/ui.data | head -30
echo '== calls in text head'; head -90 /root/fuxi/usbinit.dis | cut -c1-70
grep -n -i -E 'QcomUsbInit|UsbInitProtocol|gQcomUsbInit|USB_INIT' -r /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Silicon/Qualcomm --include=*.dec --include=*.h 2>/dev/null | cut -c50-170 | head -8

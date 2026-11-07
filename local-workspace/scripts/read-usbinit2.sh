#!/bin/bash
# Read-only: UsbInitDxe: GUIDs in .data, the installed protocol's method table, and how Start is called. Which FDs carry the module.
N=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers/UsbInitDxe
python3 -I - "$N/UsbInitDxe.efi" <<'PY'
import struct, sys, uuid
d = open(sys.argv[1], 'rb').read()
pe = struct.unpack_from('<I', d, 0x3c)[0]
n = struct.unpack_from('<H', d, pe + 6)[0]; opt = struct.unpack_from('<H', d, pe + 20)[0]
print('entry', hex(struct.unpack_from('<I', d, pe + 40)[0]), 'image base', hex(struct.unpack_from('<Q', d, pe + 24 + 24)[0]))
at = pe + 24 + opt; secs = {}
for i in range(n):
    name = d[at:at + 8].rstrip(b'\0').decode(); vs, va, rs, rp = struct.unpack_from('<IIII', d, at + 8); at += 40
    secs[name] = (va, vs, rp, rs); print(name, hex(va), hex(vs), hex(rp), hex(rs))
    if name == '.text':
        open('/tmp/ui.text', 'wb').write(d[rp:rp + rs]); open('/tmp/ui.va', 'w').write(hex(va))
va, vs, rp, rs = secs['.data']
data = d[rp:rp + rs]
known = {'3fb022e7-50b2-42ce-8ebd-5bd51812d037': 'depex'}
for o in range(0, min(len(data), 0x100), 8):
    print(hex(va + o), data[o:o + 8].hex(), struct.unpack_from('<Q', data, o)[0] if o + 8 <= len(data) else '')
for o in range(0, min(len(data), 0x100) - 15, 8):
    print('guid?', hex(va + o), uuid.UUID(bytes_le=data[o:o + 16]))
PY
llvm-objcopy -I binary -O elf64-littleaarch64 -B aarch64 --rename-section .data=.text,code /tmp/ui.text /tmp/ui.o
llvm-objdump -d --no-show-raw-insn --change-section-address .text=$(cat /tmp/ui.va) /tmp/ui.o > /root/fuxi/usbinit.dis 2>/dev/null || llvm-objdump -d --no-show-raw-insn /tmp/ui.o > /root/fuxi/usbinit.dis
wc -l < /root/fuxi/usbinit.dis
strings -a -n 6 -t x "$N/UsbInitDxe.efi" | grep -E 'UsbInit|Controller|Core' | cut -c1-90 | head -20
echo '== indirect calls and first lines'; sed -n 1,10p /root/fuxi/usbinit.dis | cut -c1-70
grep -c blr /root/fuxi/usbinit.dis
echo '== nuwa drivers holding the depex GUID (who publishes config) and in the fv list'
grep -n -E 'UsbInitDxe|UsbConfigDxe|UsbDeviceDxe|ClockDxe|PmicDxe|RpmhDxe|SmemDxe' /root/fuxi/fw/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc | cut -c1-90

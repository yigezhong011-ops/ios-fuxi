#!/bin/bash
# Read-only: in UsbConfigDxe's ConfigUsb, which mode value leads to device init. Prints the code before the device-init error string's use.
N=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers/UsbConfigDxe/UsbConfigDxe.efi
python3 -I - "$N" <<'PY'
import re, struct, subprocess, sys
d = open(sys.argv[1], 'rb').read()
pe = struct.unpack_from('<I', d, 0x3c)[0]
n = struct.unpack_from('<H', d, pe + 6)[0]; opt = struct.unpack_from('<H', d, pe + 20)[0]
at = pe + 24 + opt; text = None
for i in range(n):
    name = d[at:at + 8].rstrip(b'\0').decode(); vs, va, rs, rp = struct.unpack_from('<IIII', d, at + 8); at += 40
    if name == '.text': text = (va, rp, rs)
va, rp, rs = text
open('/tmp/uc.text', 'wb').write(d[rp:rp + rs])
subprocess.run('llvm-objcopy -I binary -O elf64-littleaarch64 -B aarch64 --rename-section .data=.text,code /tmp/uc.text /tmp/uc.o', shell=True)
out = subprocess.run('llvm-objdump -d --no-show-raw-insn /tmp/uc.o', shell=True, capture_output=True, text=True).stdout.splitlines()
out = [l for l in out if re.match(r'\s+[0-9a-f]+:', l)]
open('/root/fuxi/usbconfig.dis', 'w').write('\n'.join(out))
for needle in (b'failed to perform device initializaition', b'failed to perform host initializaition', b'ConfigUsb: Error - Invalid CoreNum'):
    s = d.find(needle)
    fmt = d.rfind(b'\0', 0, s) + 1
    target = fmt - rp  # file and image offsets match in this binary; .text-relative
    page, lo = target & ~0xfff, target & 0xfff
    for i, l in enumerate(out):
        if re.search(r'add\s+x\d+, x\d+, #0x%x$' % lo, re.sub(r'\s*//.*|\s*<.*>', '', l)):
            back = out[max(0, i - 40):i + 1]
            if any('adrp' in b and hex(page) in b for b in back[-6:]):
                print('==', needle.decode(), 'used at', l.split(':')[0].strip())
                for b in back:
                    print(re.sub(r'\s*<.*>', '', b)[4:62])
                break
PY

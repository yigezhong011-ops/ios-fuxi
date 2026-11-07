#!/usr/bin/env python3
"""Temp-boot TWRP for fuxi: the ROM's recovery.img (skkk TWRP, header v4) has no kernel; take the stock kernel from the ROM's
boot.img and write a header-v4 boot image (kernel + TWRP ramdisk + TWRP cmdline) for `fastboot boot`. Nothing is flashed.
Usage: make-twrp-boot.py <boot.img> <recovery.img> <out.img>"""
import struct
import sys

PAGE = 4096


def parse(path):
    d = open(path, 'rb').read()
    assert d[:8] == b'ANDROID!', path
    ks, rs, osv, hsz = struct.unpack_from('<IIII', d, 8)
    ver = struct.unpack_from('<I', d, 40)[0]
    cmd = d[44:44 + 1536].split(b'\0')[0]
    koff = PAGE
    roff = koff + (ks + PAGE - 1) // PAGE * PAGE
    return dict(ver=ver, osv=osv, cmd=cmd, kernel=d[koff:koff + ks], ramdisk=d[roff:roff + rs])


boot, rec = parse(sys.argv[1]), parse(sys.argv[2])
for n, x in (('boot', boot), ('recovery', rec)):
    print(f"{n}: v{x['ver']} kernel {len(x['kernel'])} ramdisk {len(x['ramdisk'])} os {x['osv']:#x} cmdline {x['cmd'][:120]!r}")
assert boot['kernel'] and rec['ramdisk'] and not rec['kernel']


def pad(b):
    return b + bytes(-len(b) % PAGE)


hdr = b'ANDROID!' + struct.pack('<IIII', len(boot['kernel']), len(rec['ramdisk']), rec['osv'] or boot['osv'], 1584) \
    + bytes(16) + struct.pack('<I', 4) + rec['cmd'].ljust(1536, b'\0') + struct.pack('<I', 0)
assert len(hdr) == 1584
out = pad(hdr) + pad(boot['kernel']) + pad(rec['ramdisk'])
open(sys.argv[3], 'wb').write(out)
print(sys.argv[3], len(out), 'bytes')

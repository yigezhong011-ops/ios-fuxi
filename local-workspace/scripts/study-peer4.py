#!/usr/bin/env python3
# Read-only: identity strings around the device-tree fields, and the full kernel args, for both images.
import re, struct
for n, a in (('peer', 0x5d7d000), ('ours', 0x3b5000)):
    b = open(f'/root/fuxi/{"peer1" if n == "peer" else "peer-ours"}/m0.bin', 'rb').read()
    print('==', n)
    for off in (0x108d100, 0x1090360, 0x10903e0, 0x10904d0):
        seg = b[off:off + 96]
        print(hex(off), re.sub(rb'[^ -~]+', b'|', seg).decode())
    for key in (b'compatible', b'product-name', b'artwork-device-subtype', b'target-type', b'D72', b'J71'):
        i = b.find(key, 0x1080000, 0x10a0000)
        if i >= 0:
            print(key.decode(), hex(i), re.sub(rb'[^ -~]+', b'|', b[i:i + 80]).decode())
    i = b.find(b'debug=0x14e')
    j = b.find(b'\0', i)
    print('args:', b[i:j].decode('ascii', 'replace'))

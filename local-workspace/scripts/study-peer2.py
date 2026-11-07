#!/usr/bin/env python3
# Read-only on the images: split each boot image's kernel section into gzip members and appended data, write them to an out dir, print a map.
import struct, sys, zlib, hashlib, re, os
KEYS = [b'SXNU1R', b'PE_halt_restart', b'control_hook_owned', b'sheng', b'Darwin Kernel Version', b'iPhone15,2', b'iPad', b'FUXI', b'REBOOT', b'SCREENSHOT', b'screenshot', b'dwc3', b'UEFI', b'github']
def find_all(b, k, cap=4):
    out, i = [], 0
    while len(out) < cap:
        i = b.find(k, i)
        if i < 0: break
        out.append(hex(i)); i += 1
    return out
def show(tag, b):
    print(f'  {tag} len={len(b):#x} sha={hashlib.sha256(b).hexdigest()[:16]} head={b[:8].hex()}')
    for k in KEYS:
        h = find_all(b, k)
        if h: print(f'    {k.decode()}: {h}')
    m = re.search(rb'Darwin Kernel Version [^\0]{0,120}', b)
    if m: print('   ', m.group()[:140])
for p, out in zip(sys.argv[1::2], sys.argv[2::2]):
    os.makedirs(out, exist_ok=True)
    d = open(p, 'rb').read()
    ks, rs = struct.unpack_from('<II', d, 8)
    print('==', p, 'size', hex(len(d)), 'kernel', hex(ks), 'ramdisk', hex(rs), 'hv', struct.unpack_from('<I', d, 40)[0])
    k = d[4096:4096 + ks]
    pos, n = 0, 0
    while pos < len(k):
        if k[pos:pos + 3] == b'\x1f\x8b\x08':
            z = zlib.decompressobj(31)
            try:
                raw = z.decompress(k[pos:])
            except zlib.error as e:
                print(f'bad gzip at {pos:#x}: {e}'); pos += 1; continue
            used = len(k) - pos - len(z.unused_data)
            print(f'gz member {n} at {pos:#x} used {used:#x}')
            show('raw', raw)
            open(f'{out}/m{n}.bin', 'wb').write(raw)
            pos += used; n += 1
        else:
            nxt = k.find(b'\x1f\x8b\x08', pos + 1)
            if nxt < 0: nxt = len(k)
            print(f'plain at {pos:#x}')
            show('plain', k[pos:nxt])
            open(f'{out}/p{n}_{pos:x}.bin', 'wb').write(k[pos:nxt])
            pos = nxt
    tail = d[4096 + ks:]
    print('after kernel', hex(len(tail)), 'nonzero', sum(1 for x in tail[:4096] if x))

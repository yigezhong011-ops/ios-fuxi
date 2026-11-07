#!/usr/bin/env python3
"""Extract and print the UniXNU config from the expert boot image's payload."""
import struct
import zlib
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img')
d = p.read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
page = 4096
start = (hsize + page - 1) // page * page
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
print('gzip 主体 %d 字节' % len(body))

fat_at = None
for m in range(0, min(len(body), 8 << 20), 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat_at = m
        break
print('FAT32 卷偏移:', fat_at)
bs = body[fat_at:fat_at + 512]
bps = struct.unpack_from('<H', bs, 11)[0]
spc = bs[13]
rsvd = struct.unpack_from('<H', bs, 14)[0]
nfats = bs[16]
spf = struct.unpack_from('<I', bs, 36)[0]
root = struct.unpack_from('<I', bs, 44)[0]
fat_off = fat_at + rsvd * bps
data_off = fat_off + nfats * spf * bps
cb = bps * spc


def chain(first):
    out, cl = [], first
    while 2 <= cl < 0x0FFFFFF8 and len(out) < 200000:
        out.append(cl)
        cl = struct.unpack_from('<I', body, fat_off + cl * 4)[0] & 0x0FFFFFFF
    return out


def read(cl):
    return b''.join(body[data_off + (c - 2) * cb: data_off + (c - 1) * cb] for c in chain(cl))


def entries(first, prefix=''):
    data = read(first)
    out = []
    for i in range(0, len(data), 32):
        e = data[i:i + 32]
        if len(e) < 32 or e[0] == 0:
            break
        if e[0] == 0xE5 or e[11] == 0x0F:
            continue
        if e[0] == 0x05:
            e = b'\xe5' + e[1:]
        name = e[0:8].decode(errors='replace').rstrip()
        ext = e[8:11].decode(errors='replace').rstrip()
        attr = e[11]
        cl = struct.unpack_from('<H', e, 26)[0] | (struct.unpack_from('<H', e, 20)[0] << 16)
        size = struct.unpack_from('<I', e, 28)[0]
        full = name + ('.' + ext if ext else '')
        if full in ('.', '..'):
            continue
        out.append((prefix + '/' + full, attr & 0x10 != 0, cl, size))
    return out


def walk(first, prefix='', depth=0):
    for path, is_dir, cl, size in entries(first, prefix):
        print('  ' * depth + '%-46s %s %d B' % (path, 'DIR ' if is_dir else 'FILE', size))
        if is_dir and depth < 3:
            walk(cl, path, depth + 1)
        elif path.lower().endswith('.toml'):
            print('\n===== %s =====' % path)
            print(read(cl).decode(errors='replace'))
            print('===== end =====\n')


walk(root)

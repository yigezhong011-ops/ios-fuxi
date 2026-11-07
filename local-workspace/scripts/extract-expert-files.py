#!/usr/bin/env python3
"""Save the expert payload's files (config, GPU addon, trust cache) so our own
payload builds can use the same pieces."""
import struct
import zlib
from pathlib import Path

OUT = Path('/root/fuxi/expert-payload')
OUT.mkdir(parents=True, exist_ok=True)

d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
page = 4096
start = (hsize + page - 1) // page * page
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])

fat_at = None
for m in range(0, min(len(body), 8 << 20), 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat_at = m
        break
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
    while 2 <= cl < 0x0FFFFFF8 and len(out) < 500000:
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
        name = e[0:8].decode(errors='replace').rstrip()
        ext = e[8:11].decode(errors='replace').rstrip()
        is_dir = e[11] & 0x10
        cl = struct.unpack_from('<H', e, 26)[0] | (struct.unpack_from('<H', e, 20)[0] << 16)
        size = struct.unpack_from('<I', e, 28)[0]
        full = name + ('.' + ext if ext else '')
        if full in ('.', '..'):
            continue
        out.append((prefix + '/' + full, bool(is_dir), cl, size))
    return out


def find(first, wanted, prefix='', depth=0):
    for path, is_dir, cl, size in entries(first, prefix):
        if is_dir:
            if depth < 4:
                got = find(cl, wanted, path, depth + 1)
                if got:
                    return got
        elif wanted(path):
            return path, cl, size
    return None


def save(match, out_name):
    got = find(root, match)
    if not got:
        print('  没找到', out_name)
        return
    path, cl, size = got
    data = read(cl)[:size]
    (OUT / out_name).write_bytes(data)
    print('  %-14s -> %s  (%d B)' % (path.split('/')[-1], OUT / out_name, len(data)))


print('=== 提取 ===')
save(lambda p: p.lower().endswith('.tom'), 'unixnu.toml')
save(lambda p: p.lower().endswith('.tru'), 'trust-cache.bundle')
save(lambda p: p.lower().endswith('.gpu'), 'gpu-addon.ngpu')
save(lambda p: p.lower().endswith('.adt'), 'kernel.macho.adt')
save(lambda p: p.lower().endswith('.img'), 'scratch.img')

print('\n=== unixnu.toml ===')
toml = OUT / 'unixnu.toml'
if toml.exists():
    print(toml.read_text(errors='replace'))

print('=== 其它文件头部 ===')
for f in ('trust-cache.bundle', 'gpu-addon.ngpu', 'scratch.img'):
    p = OUT / f
    if p.exists():
        head = p.read_bytes()[:16]
        print('  %-18s %s  %s' % (f, head.hex(), head[:8]))

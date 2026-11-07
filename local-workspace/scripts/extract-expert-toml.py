#!/usr/bin/env python3
"""Pull the UniXNU config out of the expert boot image's gzip kernel field: it is
a FAT32 volume right after the firmware, so scan for the boot sector and dump
the toml."""
import re
import struct
import zlib
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img')
d = p.read_bytes()
hver = struct.unpack_from('<I', d, 40)[0]
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
page = 4096
start = (hsize + page - 1) // page * page
kernel = d[start:start + ksize]

un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(kernel)
print('gzip 主体 %d 字节，尾部设备树 %d 字节' % (len(body), len(un.unused_data)))

# FAT32 引导扇区: 0x55AA 结尾, OEM 名, 卷标在 0x47
at = body.find(b'\x55\xaa', 0x1fe)
cands = [m.start() - 0x1fe for m in re.finditer(b'\x55\xaa', body) if 0 < m.start() - 0x1fe < len(body)]
fat_at = None
for c in cands:
    bs = body[c:c + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat_at = c
        break
print('FAT32 引导扇区偏移:', fat_at)
if fat_at is None:
    raise SystemExit('没找到 FAT32 卷')

bs = body[fat_at:fat_at + 512]
bps = struct.unpack_from('<H', bs, 11)[0]
spc = bs[13]
rsvd = struct.unpack_from('<H', bs, 14)[0]
nfats = bs[16]
spf = struct.unpack_from('<I', bs, 36)[0]
root_clus = struct.unpack_from('<I', bs, 44)[0]
tot_sect = struct.unpack_from('<I', bs, 32)[0]
label = bs[0x47:0x52].decode(errors='replace').strip()
print('标签=%s  bytes/sector=%d  sectors/cluster=%d  保留扇区=%d  FAT 数=%d  每 FAT 扇区=%d'
      % (label, bps, spc, rsvd, nfats, spf))

base = fat_at
fat_off = base + rsvd * bps
data_off = fat_off + nfats * spf * bps
cluster_bytes = bps * spc


def cluster_chain(first):
    chain, cl = [], first
    while 2 <= cl < 0x0FFFFFF8:
        chain.append(cl)
        ent = fat_off + cl * 4
        cl = struct.unpack_from('<I', body, ent)[0] & 0x0FFFFFFF
        if len(chain) > 100000:
            break
    return chain


def read_cluster(cl):
    off = data_off + (cl - 2) * cluster_bytes
    return body[off:off + cluster_bytes]


def list_dir(first, path_hint='/'):
    data = b''.join(read_cluster(c) for c in cluster_chain(first))
    out = []
    for i in range(0, len(data), 32):
        e = data[i:i + 32]
        if len(e) < 32 or e[0] == 0:
            break
        if e[0] == 0xE5 or e[11] == 0x0F:
            continue
        name = e[0:8].decode(errors='replace').strip()
        ext = e[8:11].decode(errors='replace').strip()
        attr = e[11]
        cl = struct.unpack_from('<H', e, 26)[0] | (struct.unpack_from('<H', e, 20)[0] << 16)
        size = struct.unpack_from('<I', e, 28)[0]
        full = name + ('.' + ext if ext else '')
        if attr & 0x10:
            if full not in ('.', '..'):
                out.append((path_hint + full, 'DIR', cl, 0))
        else:
            out.append((path_hint + full, 'FILE', cl, size))
    return out


def read_file(cl, size):
    return b''.join(read_cluster(c) for c in cluster_chain(cl))[:size]


entries = list_dir(root_clus)
for path, kind, cl, size in entries:
    print('  %-28s %-4s %d B' % (path, kind, size))

for want in ('EFI', 'EFI/UNIXNU', 'EFI/UniXNU'):
    for path, kind, cl, size in entries:
        if path.upper() == want.upper() and kind == 'DIR':
            print('\n[%s]' % path)
            for sub in list_dir(cl, path + '/'):
                print('  %-34s %-4s %d B' % (sub[0], sub[1], sub[3]))
                if sub[0].lower().endswith('unixnu.toml'):
                    print('\n=== unixnu.toml ===')
                    print(read_file(sub[2], sub[3]).decode(errors='replace'))

#!/usr/bin/env python3
"""Copy an NGPUADD2 GPU addon with addons/NativeAdrenoMetal.clients replaced.

Layout: UniXNU scripts/make-gpu-addon.py. Every other entry keeps its original compressed
bytes.

--same-size rewrites the addon at exactly its old length, because the payload FAT keeps the
Data seed in its free clusters. The bluetoothd launchd override is dropped (sheng-disable-jobs
already stops bluetoothd) and the client list is padded with extra lines until the container
is byte for byte as long as before.

Two things the old version got wrong, both fatal:
  * it rebuilt the whole 12 MB blob inside the search loop, so it never finished;
  * its filler was one long run of the same hex digest, which zlib compresses to almost
    nothing (40 KB of it packed into 272 bytes), so the target size was unreachable.
Here the search is analytic (only pad8 of the changed entry's compressed size matters) and
the filler is a set of short, mostly random lines, which compress at about the rate needed.

Usage: addon-set-clients.py <in> <out> <name,name,...> [--add path=file ...] [--same-size]
"""
import random
import struct
import sys
import zlib
from pathlib import Path

CLIENTS = 'addons/NativeAdrenoMetal.clients'


def pad8(n):
    return n + (-n % 8)


def total_size(entries):
    return 24 + sum(24 + pad8(len(name.encode()) + 1) + pad8(len(packed))
                    for name, mode, size, packed in entries)


def filler_lines(count, seed=0):
    rng = random.Random(seed)
    return ['zz-filler-%s' % ''.join(rng.choice('0123456789abcdef') for _ in range(12))
            for _ in range(count)]


def main():
    args = sys.argv[1:]
    if len(args) < 3:
        sys.exit(__doc__)
    src, dst, names = Path(args[0]), Path(args[1]), args[2]
    same_size = '--same-size' in args
    adds = []
    for i, a in enumerate(args):
        if a == '--add':
            adds.append(args[i + 1].split('=', 1))

    clients = [n for n in names.split(',') if n]
    if not clients or any('/' in n or ' ' in n for n in clients):
        sys.exit('bad client names')

    data = src.read_bytes()
    if data[:8] != b'NGPUADD2':
        sys.exit('not an NGPUADD2 addon')
    count, _, total = struct.unpack_from('<IIQ', data, 8)
    if total != len(data):
        sys.exit(f'header total {total} != file size {len(data)}')
    off, entries = 24, []
    for _ in range(count):
        name_len, mode, size, csize = struct.unpack_from('<IIQQ', data, off)
        off += 24
        name = data[off:off + name_len - 1].decode()
        off += pad8(name_len)
        entries.append([name, mode, size, data[off:off + csize]])
        off += pad8(csize)

    for path, local in adds:
        if '..' in path.split('/') or path.startswith('/') or any(e[0] == path for e in entries):
            sys.exit('bad or duplicate path ' + path)
        raw = Path(local).read_bytes()
        entries.append([path, 0o644, len(raw), zlib.compress(raw, 9)])

    hit = [e for e in entries if e[0] == CLIENTS]
    if len(hit) != 1:
        sys.exit('no single clients entry')
    target_entry = hit[0]

    if same_size:
        entries = [e for e in entries if e[0] != 'daemons/com.apple.bluetoothd.plist']
        target = len(data)
        fixed = total_size([e for e in entries if e[0] != CLIENTS])
        need = target - fixed
        # need == 24 + pad8(name) + pad8(csize)
        need_csize_pad = need - 24 - pad8(len(CLIENTS.encode()) + 1)
        print('target clients pad8(csize) =', need_csize_pad)
        found = None
        for seed in range(0, 24):
            for count_extra in range(0, 120):
                extra = filler_lines(count_extra, seed)
                text = ('\n'.join(clients + extra) + '\n').encode()
                packed = zlib.compress(text, 9)
                if pad8(len(packed)) == need_csize_pad:
                    found = (seed, count_extra, len(text), len(packed))
                    target_entry[2:] = [len(text), packed]
                    break
                if pad8(len(packed)) > need_csize_pad:
                    break
            if found:
                break
        if not found:
            sys.exit('could not match the old size (need pad8 %d)' % need_csize_pad)
        print('filler: seed %d, %d extra lines, text %d, compressed %d' % found)
    else:
        text = ('\n'.join(clients) + '\n').encode()
        target_entry[2:] = [len(text), zlib.compress(text, 9)]

    body = b''
    for name, mode, size, packed in entries:
        encoded = name.encode() + b'\0'
        if len(encoded) > 160:
            sys.exit('path too long ' + name)
        body += struct.pack('<IIQQ', len(encoded), mode, size, len(packed)) + \
            encoded + bytes(-len(encoded) % 8) + packed + bytes(-len(packed) % 8)
    blob = b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(body)) + body
    dst.write_bytes(blob)
    print(f'{dst}: {len(entries)} files, {len(blob)} bytes (was {len(data)}); '
          f'clients: {" ".join(clients)}')
    if same_size and len(blob) != len(data):
        sys.exit('size mismatch after the rewrite')


main()

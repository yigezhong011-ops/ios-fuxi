#!/usr/bin/env python3
"""Set the addon's client list and keep the container length by trimming the primelist.

The primelist is the list of .metallib files the render server compiles ahead of time.
Dropping entries only means fewer shaders are warmed; it changes no behaviour the device
depends on, unlike padding the client list with names the kernel would try to match.

Usage: addon-clients-trim.py <in> <out> <name,name,...>
"""
import struct
import sys
import zlib
from pathlib import Path

CLIENTS = 'addons/NativeAdrenoMetal.clients'
PRIMELIST = 'addons/NativeAdrenoMetal.primelist'


def pad8(n):
    return n + (-n % 8)


def total_size(entries):
    return 24 + sum(24 + pad8(len(name.encode()) + 1) + pad8(len(packed))
                    for name, mode, size, packed in entries)


def main():
    src, dst, names = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
    clients = [n for n in names.split(',') if n]

    data = src.read_bytes()
    count, _, total = struct.unpack_from('<IIQ', data, 8)
    off, entries = 24, []
    for _ in range(count):
        nlen, mode, size, csize = struct.unpack_from('<IIQQ', data, off)
        off += 24
        name = data[off:off + nlen - 1].decode()
        off += pad8(nlen)
        entries.append([name, mode, size, data[off:off + csize]])
        off += pad8(csize)

    target = len(data)
    cl = [e for e in entries if e[0] == CLIENTS][0]
    pl = [e for e in entries if e[0] == PRIMELIST][0]
    primelist_lines = zlib.decompress(pl[3]).decode().splitlines()
    print('原 primelist %d 行, 压缩 %d' % (len(primelist_lines), len(pl[3])))

    text = ('\n'.join(clients) + '\n').encode()
    cl[2:] = [len(text), zlib.compress(text, 9)]
    print('新名单文本 %d → 压缩 %d' % (len(text), len(cl[3])))
    print('需要腾出 %d 字节' % (total_size(entries) - target if total_size(entries) > target else 0))

    found = None
    for drop in range(0, len(primelist_lines) + 1):
        kept = primelist_lines[:len(primelist_lines) - drop] if drop else primelist_lines
        if not kept:
            break
        candidate = ('\n'.join(kept) + '\n').encode()
        pl[2:] = [len(candidate), zlib.compress(candidate, 9)]
        if total_size(entries) == target:
            found = drop
            break
        if total_size(entries) < target:
            # went too far; try adding trailing spaces to the primelist to come back up
            for extra in range(1, 400):
                padded = candidate + b'\n' + b' ' * extra + b'\n'
                pl[2:] = [len(padded), zlib.compress(padded, 9)]
                if total_size(entries) == target:
                    found = ('drop %d, +%d 空格' % (drop, extra))
                    break
                if total_size(entries) > target:
                    break
            if found:
                break
    if found is None:
        sys.exit('凑不出同样大小')

    body = b''
    for name, mode, size, packed in entries:
        enc = name.encode() + b'\0'
        body += struct.pack('<IIQQ', len(enc), mode, size, len(packed)) + \
            enc + bytes(-len(enc) % 8) + packed + bytes(-len(packed) % 8)
    blob = b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(body)) + body
    dst.write_bytes(blob)
    print('%s: %d 条目, %d 字节（原 %d）；名单 %s；primelist 调整 %s'
          % (dst.name, len(entries), len(blob), target, ' '.join(clients), found))
    if len(blob) != target:
        sys.exit('大小不一致')


main()

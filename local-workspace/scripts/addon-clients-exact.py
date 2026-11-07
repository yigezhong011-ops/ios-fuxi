#!/usr/bin/env python3
"""Rewrite the addon's client list with NO filler and no removed entries: the new text
must land in the same pad8 bucket as the old one, so the container keeps its length.

Usage: addon-clients-exact.py <in> <out> <name,name,...>
"""
import struct
import sys
import zlib
from pathlib import Path

CLIENTS = 'addons/NativeAdrenoMetal.clients'


def pad8(n):
    return n + (-n % 8)


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

    hit = [e for e in entries if e[0] == CLIENTS][0]
    old_pad = pad8(len(hit[3]))
    print('原条目压缩 %d → pad8 %d' % (len(hit[3]), old_pad))

    found = None
    for pad in range(0, 8):
        for extra in range(0, 9):
            text = ('\n'.join(clients) + '\n' + ' ' * extra).encode()
            packed = zlib.compress(text, 9)
            if pad8(len(packed)) == old_pad:
                found = (len(text), len(packed), extra)
                hit[2:] = [len(text), packed]
                break
        if found:
            break
    if not found:
        print('这个名单压缩后落不进同一个桶，需要填充或删条目')
        for extra in range(0, 9):
            text = ('\n'.join(clients) + '\n' + ' ' * extra).encode()
            print('   补 %d 空格: %d 字节 → 压缩 %d → pad8 %d' %
                  (extra, len(text), len(zlib.compress(text, 9)), pad8(len(zlib.compress(text, 9)))))
        sys.exit(1)

    body = b''
    for name, mode, size, packed in entries:
        enc = name.encode() + b'\0'
        body += struct.pack('<IIQQ', len(enc), mode, size, len(packed)) + \
            enc + bytes(-len(enc) % 8) + packed + bytes(-len(packed) % 8)
    blob = b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(body)) + body
    dst.write_bytes(blob)
    print('%s: %d 条目, %d 字节（原 %d）；名单 %s；文本 %d、压缩 %d、尾部空格 %d'
          % (dst.name, len(entries), len(blob), len(data), ' '.join(clients), *found))
    if len(blob) != len(data):
        sys.exit('大小不一致')


main()

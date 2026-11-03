#!/usr/bin/env python3
"""Make a rebuilt GPU addon exactly the size of the one already in the payload volume.

The payload's FAT keeps the Data seed in its free clusters, so an addon file must be
replaced in place at the same size. Two cases:

  new smaller  -> append one filler entry whose compressed payload makes up the difference
  new larger   -> report the deficit and the entries that could be dropped to recover it

Usage: fit-addon.py <original addon> <new addon> <out addon>
"""
import struct
import sys
import zlib
from pathlib import Path


def pad8(n):
    return n + (-n % 8)


def parse(blob):
    count, _, total = struct.unpack_from('<IIQ', blob, 8)
    off, entries = 24, []
    for _ in range(count):
        nlen, mode, size, csize = struct.unpack_from('<IIQQ', blob, off)
        off += 24
        name = blob[off:off + nlen - 1].decode()
        off += pad8(nlen)
        entries.append([name, mode, size, blob[off:off + csize]])
        off += pad8(csize)
    return entries


def build(entries):
    body = b''
    for name, mode, size, packed in entries:
        enc = name.encode() + b'\0'
        body += struct.pack('<IIQQ', len(enc), mode, size, len(packed)) + \
            enc + bytes(-len(enc) % 8) + packed + bytes(-len(packed) % 8)
    return b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(body)) + body


def main():
    orig, new, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    target = orig.stat().st_size
    entries = parse(new.read_bytes())
    blob = build(entries)
    print('原件 %d 字节，新件 %d 字节，差 %+d' % (target, len(blob), target - len(blob)))

    if len(blob) == target:
        out.write_bytes(blob)
        print('大小已一致，直接写出')
        return

    if len(blob) > target:
        print('新件偏大，需要腾出 %d 字节。可考虑删除的条目：' % (len(blob) - target))
        for name, mode, size, packed in entries:
            print('   %-58s 压缩 %8d  pad8 %8d' % (name[:58], len(packed), pad8(len(packed))))
        sys.exit(1)

    deficit = target - len(blob)
    # one filler entry: 24 header + pad8(name) + pad8(csize) must equal the deficit
    for name_len in range(8, 60):
        name = ('addons/NativeAdrenoMetal.f' + 'x' * 40)[:name_len]
        rest = deficit - 24 - pad8(len(name) + 1)
        if rest <= 0 or rest % 8:
            continue
        for attempt in range(200000):
            payload = ('filler-%d\n' % attempt).encode() + bytes(attempt % 251 for _ in range(max(0, rest * 3 // 2)))
            packed = zlib.compress(payload, 9)
            if pad8(len(packed)) == rest:
                entries.append([name, 0o644, len(payload), packed])
                blob = build(entries)
                if len(blob) == target:
                    out.write_bytes(blob)
                    print('加了填充条目 %s（payload %d 字节，压缩 %d）→ %d 字节'
                          % (name, len(payload), len(packed), len(blob)))
                    return
                entries.pop()
                break
    sys.exit('凑不出同样大小')


main()

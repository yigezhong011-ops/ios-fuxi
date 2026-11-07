#!/usr/bin/env python3
"""Make a rebuilt GPU addon exactly the size of the one already in the payload volume.

The payload's FAT keeps the Data seed in its free clusters, so the addon must be replaced
in place at the same size. The earlier version brute-forced zlib output sizes and ran for
hours; this computes the entry layout and picks the payload length analytically.

Usage: fit-addon.py <original addon> <new addon> <out addon>
"""
import os
import struct
import sys
import zlib
from pathlib import Path


def pad8(n):
    return n + (-n % 8)


def parse(blob):
    count, _, _total = struct.unpack_from('<IIQ', blob, 8)
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
    print('原件 %d，新件 %d，差 %+d 字节' % (target, len(blob), target - len(blob)))

    if len(blob) == target:
        out.write_bytes(blob)
        print('大小已一致，直接写出')
        return

    if len(blob) > target:
        print('新件偏大 %d 字节，需要删条目：' % (len(blob) - target))
        for name, mode, size, packed in entries:
            print('   %-56s 压缩 %8d  条目 %8d' %
                  (name[:56], len(packed), 24 + pad8(len(name) + 1) + pad8(len(packed))))
        sys.exit(1)

    deficit = target - len(blob)
    print('需要填补 %d 字节' % deficit)
    for name_len in range(32, 80):
        name = ('addons/NativeAdrenoMetal.filler' + 'x' * 80)[:name_len]
        overhead = 24 + pad8(len(name) + 1)
        rest = deficit - overhead
        if rest < 16 or rest % 8:
            continue
        # zlib's overhead on an incompressible payload grows with its size (stored-block
        # headers), so measure it once and search around that.
        extra = len(zlib.compress(os.urandom(rest), 9)) - rest
        for n in range(max(8, rest - extra - 60), rest - extra + 60):
            payload = os.urandom(n)
            packed = zlib.compress(payload, 9)
            if pad8(len(packed)) == rest:
                entries.append([name, 0o644, len(payload), packed])
                blob = build(entries)
                if len(blob) == target:
                    out.write_bytes(blob)
                    print('填充条目 %s：payload %d 字节，压缩 %d 字节 → 总计 %d'
                          % (name, len(payload), len(packed), len(blob)))
                    return
                entries.pop()
                break
    sys.exit('凑不出同样大小（deficit=%d）' % deficit)


main()

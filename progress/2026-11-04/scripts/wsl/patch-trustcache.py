#!/usr/bin/env python3
"""Replace the owner module's CDHashes in the payload trust cache, in place, same size.

Bundle layout (scripts/make-owner-trust-bundle.py):
  u32 module_count, u32 starts[module_count], then each module
  module: u32 version(2), 16-byte uuid, u32 entries, then entries of 20-byte CDHash + 4 bytes
The boot loader requires each module's hashes to be strictly ascending and the entry count
to stay the same, so the file length never changes.

Usage: patch-trustcache.py <trustcache.bin> <cdhashes.txt> <out.bin>
cdhashes.txt is the CI output: lines of "<40 hex> <relative path>".
"""
import struct
import sys
from pathlib import Path


def parse(data):
    count = struct.unpack_from('<I', data)[0]
    starts = list(struct.unpack_from('<%dI' % count, data, 4))
    modules = []
    for i, start in enumerate(starts):
        end = starts[i + 1] if i + 1 < count else len(data)
        modules.append((start, end))
    return count, starts, modules


def main():
    src, hashes_file, dst = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    data = bytearray(src.read_bytes())
    count, starts, modules = parse(data)
    print('模块数 %d，起始 %s' % (count, starts))

    entries = [line.split()[0] for line in hashes_file.read_text().splitlines() if line.strip()]
    entries = [e for e in entries if len(e) == 40]
    print('新哈希 %d 个:' % len(entries))
    for e in entries:
        print('   ', e)

    start, end = modules[0]
    version, entries_count = struct.unpack_from('<I', data, start)[0], struct.unpack_from('<I', data, start + 20)[0]
    print('owner 模块: version=%d entries=%d 长度=%d' % (version, entries_count, end - start))
    if version != 2 or end - start != 24 + entries_count * 24:
        sys.exit('不是完整的 version-2 模块')
    if entries_count != len(entries):
        sys.exit('条目数必须保持不变（%d != %d）' % (entries_count, len(entries)))

    raw = sorted(bytes.fromhex(e) for e in entries)
    for a, b in zip(raw, raw[1:]):
        if a >= b:
            sys.exit('哈希重复，loader 会拒绝')
    for i, h in enumerate(raw):
        at = start + 24 + i * 24
        data[at:at + 20] = h
        data[at + 20:at + 24] = bytes([2, 0, 0, 0])

    dst.write_bytes(bytes(data))
    print('写出 %s（%d 字节，与原文件%s）' % (dst.name, len(data), '相同' if len(data) == len(src.read_bytes()) else '不同'))


main()

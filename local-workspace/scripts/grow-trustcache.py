#!/usr/bin/env python3
"""Rewrite the owner module of the trust cache with a different number of hashes; the other modules move and stay byte for byte.
Layout: u32 count, u32 starts[count], modules; module: u32 version, 16-byte uuid, u32 entries, then 20-byte CDHash + 4 bytes, ascending.
Usage: grow-trustcache.py <in> <cdhashes.txt> <out>. Every hash but the replaced plugin's must already be in the owner module."""
import struct, sys

d = open(sys.argv[1], 'rb').read()
n = struct.unpack_from('<I', d)[0]; starts = list(struct.unpack_from('<%dI' % n, d, 4))
s = starts[0]; old = struct.unpack_from('<I', d, s + 20)[0]; end = s + 24 + old * 24
assert struct.unpack_from('<I', d, s)[0] == 2 and end == starts[1]
have = {d[s + 24 + i * 24:s + 44 + i * 24].hex() for i in range(old)}
lines = [l.split() for l in open(sys.argv[2]) if l.strip()]
for h, name in lines:
    if name.endswith(('libvulkan_freedreno.dylib', 'adrenoprobed')): assert h in have, name
raw = sorted(bytes.fromhex(h) for h, _ in lines)
assert all(a < b for a, b in zip(raw, raw[1:]))
owner = d[s:s + 20] + struct.pack('<I', len(raw)) + b''.join(h + bytes([2, 0, 0, 0]) for h in raw)
delta = len(owner) - (end - s)
head = struct.pack('<I', n) + struct.pack('<%dI' % n, starts[0], *[x + delta for x in starts[1:]])
assert len(head) == s
out = head + owner + d[end:]
assert out[-(len(d) - end):] == d[end:]
open(sys.argv[3], 'wb').write(out)
print('owner hashes', old, '->', len(raw), 'file', len(d), '->', len(out))

#!/usr/bin/env python3
"""Which byte ranges of the partition an Android sparse image writes (raw/fill chunks), merged. Read-only.
Usage: simg-ranges.py <img.simg> [partition-bytes]"""
import struct
import sys

f = open(sys.argv[1], 'rb')
magic, major, minor, fhdr, chdr, blk, total_blks, total_chunks, _ = struct.unpack('<IHHHHIIII', f.read(28))
assert magic == 0xed26ff3a, hex(magic)
f.seek(fhdr)
print(f'block {blk}, partition image {total_blks * blk / 2**30:.2f} GiB, {total_chunks} chunks')
pos, runs, kinds = 0, [], {}
for _ in range(total_chunks):
    ctype, _, csz, tot = struct.unpack('<HHII', f.read(chdr))
    f.seek(tot - chdr, 1)
    kinds[ctype] = kinds.get(ctype, 0) + 1
    if ctype in (0xCAC1, 0xCAC2):   # raw, fill: written
        if runs and runs[-1][1] == pos:
            runs[-1][1] = pos + csz
        else:
            runs.append([pos, pos + csz])
    pos += csz
print('chunk kinds', {hex(k): v for k, v in kinds.items()})
for s, e in runs:
    print(f'  writes {s * blk / 2**30:9.3f} .. {e * blk / 2**30:9.3f} GiB  ({(e - s) * blk / 2**20:.0f} MiB)')
if len(sys.argv) > 2:
    part = int(sys.argv[2])
    print(f'partition {part / 2**30:.3f} GiB; image ends at {pos * blk / 2**30:.3f} GiB')

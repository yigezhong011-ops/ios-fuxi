#!/usr/bin/env python3
# Read-only scan of the raw Data window: APFS block types, SQLite heads and poster store text, by 4K block.
import collections, struct, sys
P = sys.argv[1]
BLOCK = 4096
CHUNK = BLOCK * 4096
NEEDLES = [b'PRBPosterExtensionDataStore', b'com.apple.migration', b'ngpu/wallpaper', b'353FB615-9AD2-407D-B79C-EFF255D5432B']
hits = collections.Counter()
first = {}
types = collections.Counter()
nxsb, apsb, sqlite = [], [], []
with open(P, 'rb') as f:
    n = 0
    tail = b''
    while True:
        d = f.read(CHUNK)
        if not d:
            break
        for off in range(0, len(d) - BLOCK + 1, BLOCK):
            head = d[off:off + 40]
            b = n + off // BLOCK
            m = head[32:36]
            if m == b'NXSB':
                nxsb.append(b)
            elif m == b'APSB':
                apsb.append(b)
            if head[:16] == b'SQLite format 3\0':
                sqlite.append(b)
            types[struct.unpack_from('<H', head, 24)[0]] += 1
        joined = tail + d
        for s in NEEDLES:
            at = joined.find(s)
            while at != -1:
                if at + len(s) > len(tail):
                    hits[s] += 1
                    first.setdefault(s, n + (at - len(tail)) // BLOCK)
                at = joined.find(s, at + 1)
        tail = d[-64:]
        n += len(d) // BLOCK
print('blocks', n)
print('NXSB', len(nxsb), nxsb[:12])
print('APSB', len(apsb), apsb[:12])
print('SQLite heads', len(sqlite), sqlite[:12])
for s in NEEDLES:
    print(s.decode(), 'hits', hits[s], 'first block', first.get(s))
print('common object types at offset 24:', [(hex(k), v) for k, v in types.most_common(12)])

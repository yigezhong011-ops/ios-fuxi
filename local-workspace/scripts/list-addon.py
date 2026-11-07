#!/usr/bin/env python3
# Read only: entries of a GPU addon with raw and packed sizes. Usage: list-addon.py <addon>
import struct, sys
b = open(sys.argv[1], 'rb').read()
c = struct.unpack_from('<I', b, 8)[0]; at = 24; rows = []
for _ in range(c):
    nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
    n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
    rows.append((pk, s, n)); at += (pk + 7) // 8 * 8
print('bytes', len(b), 'entries', c)
for pk, s, n in sorted(rows, reverse=True):
    print('%9d %9d %s' % (pk, s, n))

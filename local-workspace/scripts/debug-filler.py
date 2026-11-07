#!/usr/bin/env python3
"""Why does the filler search fail? Print the real compressed sizes around the target."""
import os
import zlib

deficit = 141184
print('deficit', deficit, 'div8', deficit % 8)


def pad8(n):
    return n + (-n % 8)


for name_len in (20, 24, 32, 40):
    name = ('addons/NativeAdrenoMetal.fill' + 'x' * 80)[:name_len]
    overhead = 24 + pad8(len(name) + 1)
    rest = deficit - overhead
    print('\nname_len', name_len, 'name', name, 'overhead', overhead, 'rest', rest, 'rest%8', rest % 8)
    hits = 0
    for n in range(max(8, rest - 40), rest):
        packed = zlib.compress(os.urandom(n), 9)
        if pad8(len(packed)) == rest:
            hits += 1
            if hits <= 2:
                print('   命中 n=%d → 压缩 %d → pad8 %d' % (n, len(packed), pad8(len(packed))))
    print('   命中数', hits)

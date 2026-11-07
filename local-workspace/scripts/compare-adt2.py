#!/usr/bin/env python3
"""Compare the string tables of the two ADTs (old zip payload vs our build)."""
import re
from pathlib import Path

W = Path('/root/fuxi/adtcmp')
theirs = (W / 'theirs.adt').read_bytes()
ours = (W / 'ours.adt').read_bytes()

pat = re.compile(rb'[ -~]{5,}')


def strings(b):
    return {m.group().decode() for m in pat.finditer(b)}


st, so = strings(theirs), strings(ours)
print('theirs %d strings, ours %d strings' % (len(st), len(so)))
print()
print('=== 只在旧 payload 里 ===')
for s in sorted(st - so)[:30]:
    print('  -', s)
print()
print('=== 只在新 payload 里 ===')
for s in sorted(so - st)[:30]:
    print('  +', s)
print()
keys = ('img4', 'mix', 'trust', 'csr', 'amfi', 'secur', 'sig')
print('=== 信任/签名相关的（两边）===')
for s in sorted(x for x in (so | st) if any(k in x.lower() for k in keys)):
    where = 'both' if s in st and s in so else ('ours' if s in so else 'theirs')
    print('  %-42s %s' % (s, where))

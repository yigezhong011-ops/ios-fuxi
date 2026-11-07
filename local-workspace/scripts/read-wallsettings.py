#!/usr/bin/env python3
# Read-only: why Settings > Wallpaper closes. The candidate's boot against the wall17 capture.
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wall17/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallsettings/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for o, c in sorted(new)).decode('latin1')
print('fresh blocks', len(new), 'bytes', len(t))
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:260]
def top(title, pat, n, skip=None):
    c = Counter(N(l) for l in L if re.search(pat, l) and not (skip and re.search(skip, l)))
    print('==', title, sum(c.values()))
    for k, v in c.most_common(n): print(v, k)
def ctx(pat, n=4, before=14, after=8):
    idx = [i for i, l in enumerate(L) if re.search(pat, l)]
    print('== context', pat, len(idx))
    last = -10000; k = 0
    for i in idx:
        if i - last < 800: continue
        last = i; k += 1
        if k > n: break
        for x in L[max(0, i - before):i + after]: print('  ', x[:230])
        print('  -----')
top('uncaught and aborts', r'Terminating app|uncaught|Assertion failed|exited due to|abort\(\) called|attempt to insert nil|dataStore', 25)
top('Preferences', r'com\.apple\.Preferences|Preferences\[|WallpaperSettings|PosterBoardUI|PRUIS|PUI\w+Poster|PBFGallery|PBFModal', 18, skip=r'^file:|RBS|Sandbox')
top('Metal', r'device refused|_metalContext|MTLCreate|Metal failed|pipelineState', 12)
ctx(r'Terminating app|attempt to insert nil')
ctx(r'exited due to SIG[A-Z]+ \| sent by (PosterBoard|Preferences)', 3, 10, 4)

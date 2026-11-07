#!/usr/bin/env python3
# Read-only: the wall17 boot against the wallred3 capture. Who aborts and why, who asks for Metal, what the sandbox refuses.
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallred3/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wall17/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for o, c in sorted(new)).decode('latin1')
print('fresh blocks', len(new), 'bytes', len(t))
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:200]
for p in ('did not contain a top-level dictionary', 'LayeredAnimation', 'WKBokehView', '7570.iPadOS_17_Flat_Background', 'J120.jpg', 'J120-Dark.jpg', 'CGImage', 'Terminating app', 'exited due to SIGABRT'):
    print('%7d %s' % (t.count(p), p))
def top(title, pat, n, skip=None):
    c = Counter(N(l) for l in L if re.search(pat, l) and not (skip and re.search(skip, l)))
    print('==', title, sum(c.values()))
    for k, v in c.most_common(n): print(v, k)
def ctx(pat, n=3, before=6, after=3):
    idx = [i for i, l in enumerate(L) if re.search(pat, l)]
    print('== context', pat, len(idx))
    last = -10000; k = 0
    for i in idx:
        if i - last < 1500: continue
        last = i; k += 1
        if k > n: break
        for x in L[max(0, i - before):i + after]: print('  ', x[:170])
        print('  -----')
top('aborts', r'exited due to|EXC_[A-Z]+|Terminating app|abort\(\)|Assertion failed', 25)
top('who was killed', r'[A-Za-z_.]+\[\d+\].*(exited|crash)|termination reason|Termination Reason', 15)
top('Metal and accelerator', r'(?i)MTLCreate|MTLDevice|NativeAdreno|AdrenoMetal|no-cachedir|newTextureLayout|OutOfMemory|IOAccel|AGXDeviceUserClient|Metal.*(fail|error|nil|unavailable)', 30)
top('sandbox refusals of the GPU', r'Sandbox:.*(AGX|IOAccel|iokit-open)', 15)
ctx(r'exited due to SIGABRT', 3)

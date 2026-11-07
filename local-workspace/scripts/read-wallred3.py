#!/usr/bin/env python3
# Read-only: the in-place red boot against the previous capture. Was the plist accepted, did the Bokeh view run, did the scene settle.
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallred/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallred2/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for o, c in sorted(new)).decode('latin1')
print('fresh blocks', len(new), 'bytes', len(t))
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:230]
for p in ('did not contain a top-level dictionary', 'WKBokehView', '_enableAnimation', '_disableAnimation', 'PRRenderer', 'Poster scene is not ready', 'PBFPosterSnapshotter is running', 'Terminating app', 'exited due to SIGABRT', 'CAEmitter', 'Bokeh'):
    print('%7d %s' % (t.count(p), p))
def top(title, pat, n, skip=None):
    c = Counter(N(l) for l in L if re.search(pat, l) and not (skip and re.search(skip, l)))
    print('==', title, sum(c.values()))
    for k, v in c.most_common(n): print(v, k)
top('scene readiness', r'Poster scene|\[home\]|\[lock\]', 12)
top('snapshot results', r'(?i)PBFPosterSnapshot\w*.*(fail|error|finish|complete|result)|snapshot.*(fail|error)', 15, skip=r'AMSError|ICError|MapKit|Snapshot Cache')
top('poster errors', r'(?i)(poster|wallpaper|PBF|PRS|PBUI).*(error|fail|unable|invalid)', 20, skip=r'^file:|PRPosterConfigurableOptions|Sandbox:|^-\[|^\+\[|providerInfoSetObject')

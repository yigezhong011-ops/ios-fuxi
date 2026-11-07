#!/usr/bin/env python3
# Read-only: wallred boot against the wallcat capture. Was the poster scene visible, and what SpringBoard says about it.
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallcat/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallred/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for o, c in sorted(new)).decode('latin1')
print('fresh blocks', len(new), 'bytes', len(t))
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:230]
def top(title, pat, n, skip=None):
    c = Counter(N(l) for l in L if re.search(pat, l) and not (skip and re.search(skip, l)))
    print('==', title, sum(c.values()))
    for k, v in c.most_common(n): print(v, k)
def ctx(pat, n=2, before=10, after=8):
    idx = [i for i, l in enumerate(L) if re.search(pat, l)]
    print('== context', pat, len(idx))
    last = -10000; k = 0
    for i in idx:
        if i - last < 1500: continue
        last = i; k += 1
        if k > n: break
        for x in L[max(0, i - before):i + after]: print('  ', x[:190])
        print('  -----')
for p in ('5010', 'Wallpaper.plist', 'WKBokehView', 'PRRenderer', 'NotVisible', 'Poster scene', 'FF0000', 'AGXDeviceUserClient', 'CollectionsPoster'):
    print('%7d %s' % (t.count(p), p))
top('poster scene and lock views', r'Poster scene|PBUIPoster|_UIScenePresenter.*Poster|PosterKit:|SceneLayer|sceneLayer|LayerHost|portal|Portal', 25, skip=r'^file:')
top('5010 lines', r'\b5010\b', 15, skip=r'^file:|PRPosterConfigurableOptions')
top('Collections poster process', r'CollectionsPoster', 25, skip=r'^file:|^-|Sandbox|_EXHostConfiguration')
top('home wallpaper', r'\[home\]|\[lock\]|wallpaperStyle|PBUIWallpaper|replica|Replica', 20, skip=r'^file:')
top('backlight/visible', r'(?i)isVisible|visibility|deactivationReasons|-NotVisible|occluded', 15, skip=r'^file:')
ctx(r'<PRRenderer:', 2, 6, 6)
ctx(r'Poster scene is not ready', 2, 8, 6)
ctx(r'WKBokehView _enableAnimation', 1, 8, 4)

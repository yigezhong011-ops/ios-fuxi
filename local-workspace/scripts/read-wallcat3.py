#!/usr/bin/env python3
# Read-only: how far the poster render gets in the wallcat boot: Bokeh view, snapshots, scene, layers, Metal.
import hashlib, re
from collections import Counter
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-storefix2/lscan.txt')}
t = b'\n'.join(c for o, c in sorted(blocks('/mnt/e/DSH-Fuxi/logs/carve-wallcat/lscan.txt')) if hashlib.sha1(c).digest() not in old).decode('latin1')
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
N = lambda l: re.sub(r'0x[0-9a-f]+|[0-9A-Fa-f]{8}-[0-9A-Fa-f-]{27}|\d+', '#', l)[:200]
def top(title, pat, n, flags=0, skip=None):
    c = Counter(N(l) for l in L if re.search(pat, l, flags) and not (skip and re.search(skip, l)))
    print('==', title, sum(c.values()))
    for k, v in c.most_common(n): print(v, k)
def ctx(pat, n=2, before=14, after=8):
    idx = [i for i, l in enumerate(L) if re.search(pat, l)]
    print('== context', pat, len(idx))
    last = -10000
    k = 0
    for i in idx:
        if i - last < 2000: continue
        last = i; k += 1
        if k > n: break
        for x in L[max(0, i - before):i + after]: print('  ', x[:170])
        print('  -----')
top('snapshot', r'(?i)snapshot', 25, skip=r'^file:')
top('render controller and layer', r'WKWallpaperPoster|WKBokeh|PRRenderer|PRSceneViewController|PBFPosterRender|PBFRenderer|PosterRender', 25)
top('scene', r'(?i)(com\.apple\.WallpaperKit\.CollectionsPoster).*(scene|foreground|background|invalidat|render)|PRSScene|PBFApplicationStateMonitor', 12)
top('posters and config', r'(?i)activeConfiguration|active poster|selectedConfiguration|PBFPosterGallery|switcher|PBUIPoster|PBUIWallpaper|updateToPosterConfiguration|posterPath|wallpaperPoster', 25, skip=r'^file:|PRPosterConfigurableOptions')
top('wallpaper service', r'(?i)PBUI\w+|SBWallpaper\w+|wallpaper.*(fail|error|unable|black|none|nil)', 25, skip=r'^file:|PRPosterConfigurableOptions')
top('private generalError', r'generalErrorDomain', 4)
ctx(r'generalErrorDomain', 2, 16, 6)
ctx(r'-\[WKBokehView _enableAnimation\]', 1, 12, 10)
ctx(r'CacheManagerManifest', 1, 6, 4)

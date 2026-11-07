#!/usr/bin/env python3
"""The stack in the first block of the PosterBoard reports, and any readable reason nearby. Read-only."""
import re
from collections import Counter
from pathlib import Path

b = Path('/mnt/e/DSH-Fuxi/logs/crashes/chunk.dat').read_bytes()
base = 64 * 1024 * 1024
h = 32288768
blk = b[base + h:base + h + 4096].decode(errors='replace')
print(blk[:900])
print('-- used images and frames')
at = blk.find('"threads"')
print(blk[at:at + 120])
for m in re.finditer(r'\{"imageOffset":(\d+)(?:,"symbol":"([^"]*)","symbolLocation":(\d+))?,"imageIndex":(\d+)\}', blk):
    print('  ', m[4].rjust(3), hex(int(m[1])).ljust(10), (m[2] or '?')[:100], m[3] or '')
print('-- registers strings')
for m in re.finditer(r'"objc-selector":"([^"]+)"|"sourceFile":"([^"]+)"|"symbol":"([^"]+)"', blk[:at + 1400]):
    print('  ', m[0][:110])
print('-- continuation candidates: blocks of frames that hold the rest of UIKit startup')
for pat in (rb'workspace:didCreateScene', rb'_connectUISceneFromFBSScene', rb'PBFPosterSnapshot|PRSPoster|PRPoster|PBFPoster|PBFApplication|PBFDataStore|PosterBoardSupport|PosterBoardUI|PosterFoundation'):
    hits = [m.start() for m in re.finditer(pat, b)]
    print(pat[:40], len(hits), [x - base for x in hits[:12]])
print('-- reason text')
c = Counter()
for m in re.finditer(rb'[ -~]{0,120}(?:Fatal error|Unexpectedly found nil|Assertion failed|NSInternalInconsistency|BSServiceConnection|Unable to|failed to)[ -~]{0,180}', b[base + h - 40000000:base + h + 40000000]):
    t = m[0].decode(errors='replace')
    if re.search(r'Poster|Wallpaper|PaperBoard|Metal|Scene|Fatal error', t):
        c[re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}', '#', t)[:230]] += 1
for k, v in c.most_common(30):
    print(v, k)

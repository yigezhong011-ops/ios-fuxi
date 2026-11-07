#!/usr/bin/env python3
"""Find the continuation of the PosterBoard crash reports in the chunk: blocks with frames, images, and reason text. Read-only."""
import re
from pathlib import Path

b = Path('/mnt/e/DSH-Fuxi/logs/crashes/chunk.dat').read_bytes()
print('chunk', len(b))
base = 64 * 1024 * 1024   # file offset of MiB 212167
heads = [32288768, 32301056, 32309248, 32501760]
for h in heads:
    print('head at', base + h, b[base + h:base + h + 40])
    print('  tail of first block:', b[base + h + 3990:base + h + 4120])
    print('  next block starts :', b[base + h + 4096:base + h + 4160])
for pat in (rb'"name":"PosterBoard"', rb'PosterBoard\.app/PosterBoard"', rb'"procName":"PosterBoard"', rb'Fatal error', rb'"asi" ?: ?\{', rb'"legacyInfo"', rb'"lastExceptionBacktrace"', rb'BUG IN CLIENT', rb'"imageExtraInfo"', rb'PosterKit|PosterBoardServices|PaperBoard|WallpaperKit', rb'"frames":\['):
    hits = [m.start() for m in re.finditer(pat, b)]
    print(pat, len(hits), hits[:10])

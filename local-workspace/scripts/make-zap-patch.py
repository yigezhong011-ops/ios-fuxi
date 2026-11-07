#!/usr/bin/env python3
"""Patch 0111: accept the GPU bring-up even when the ZAP stage does not report 1."""
import difflib
from pathlib import Path

SRC = Path('/root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c')
OUT = Path('/root/fuxi/0111-fuxi-gpu-zap-optional.patch')

src = SRC.read_text().splitlines(keepends=True)

old = [
    ' if (fg_access_failed || gpu_extra[5][4] != 1 ||\n',
    '     (fg_limit != 13 && gpu_extra[13][2] != 1)) {\n',
]
new = [
    ' /* ZAP (secure shader) is only needed for protected content; normal\n',
    '  * composition and scanout do not use it. Accept a non-1 zap result. */\n',
    ' if (fg_access_failed || gpu_extra[5][4] != 1) {\n',
]

out = []
done = False
i = 0
while i < len(src):
    if not done and src[i] == old[0] and i + 1 < len(src) and src[i + 1] == old[1]:
        out.extend(new)
        i += 2
        done = True
        continue
    out.append(src[i])
    i += 1

assert done, 'zap condition not found'

diff = list(difflib.unified_diff(
    src, out,
    fromfile='a/bsd/dev/fuxi_adreno.c',
    tofile='b/bsd/dev/fuxi_adreno.c',
    n=3))
text = ''.join(diff)
OUT.write_bytes(text.encode('utf-8'))
print(text)
print('bytes:', len(text))
for n, line in enumerate(text.splitlines()[:12], 1):
    print(f'{n:2}| {line[:100]}')

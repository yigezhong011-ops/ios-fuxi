#!/usr/bin/env python3
"""Find the clang invocation that compiles NativeAdrenoMetalPlugin.mm at 793d6bddf7."""
import urllib.request

H = {'User-Agent': 'dsh'}
REF = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
REPO = 'UniXNU/UniXNU'
url = f'https://raw.githubusercontent.com/{REPO}/{REF}/scripts/build-adreno-metal-plugin.py'
text = urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60).read().decode()
lines = text.splitlines()
print('总行数', len(lines))
for i, line in enumerate(lines, 1):
    if '-Werror' in line or 'NativeAdrenoMetalPlugin.mm' in line or 'clang++' in line:
        lo, hi = max(0, i - 6), min(len(lines), i + 10)
        print('--- 第 %d 行附近 ---' % i)
        for j in range(lo, hi):
            print('%4d| %s' % (j + 1, lines[j][:190]))
        print()

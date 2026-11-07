#!/usr/bin/env python3
"""Find the plugin watchdog assertion and any knob around it."""
import urllib.request

H = {'User-Agent': 'dsh'}
REF = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
REPO = 'UniXNU/UniXNU'

url = f'https://raw.githubusercontent.com/{REPO}/{REF}/scripts/check-turnip-darwin-host.py'
text = urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60).read().decode()

lines = text.splitlines()
for i, line in enumerate(lines, 1):
    if 'watchdog' in line.lower():
        lo, hi = max(0, i - 6), min(len(lines), i + 8)
        print('--- %d ---' % i)
        for j in range(lo, hi):
            print('%4d| %s' % (j + 1, lines[j][:170]))
        print()

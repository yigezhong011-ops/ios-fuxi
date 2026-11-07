#!/usr/bin/env python3
"""What does gen-turnip-replay.py do after the check?"""
import urllib.request

H = {'User-Agent': 'dsh'}
REF = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
REPO = 'UniXNU/UniXNU'
url = f'https://raw.githubusercontent.com/{REPO}/{REF}/scripts/gen-turnip-replay.py'
text = urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60).read().decode()
print('行数', len(text.splitlines()))
for i, line in enumerate(text.splitlines()[:60], 1):
    print('%4d| %s' % (i, line[:160]))

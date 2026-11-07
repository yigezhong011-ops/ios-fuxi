#!/usr/bin/env python3
"""Show the main-branch build-sheng-platform-power.py around the audit call."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
req = urllib.request.Request(f'https://api.github.com/repos/{REPO}/contents/scripts/build-sheng-platform-power.py?ref=main', headers=H)
cur = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
text = base64.b64decode(cur['content']).decode()
for i, line in enumerate(text.splitlines(), 1):
    if 15 <= i <= 45:
        print('%3d| %s' % (i, line))

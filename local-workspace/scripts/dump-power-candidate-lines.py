#!/usr/bin/env python3
"""Dump the candidate section of the old-branch power script."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
req = urllib.request.Request(f'https://api.github.com/repos/{REPO}/contents/scripts/build-sheng-platform-power.py?ref=old', headers=H)
cur = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
text = base64.b64decode(cur['content']).decode()
lines = text.splitlines()
for i, line in enumerate(lines, 1):
    if 'candidate' in line or 'import' in line or 'args =' in line or 'parser' in line:
        print('%3d| %s' % (i, line[:120]))

#!/usr/bin/env python3
"""Fetch a docs-lanes file from the repo and print it."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'

for name in ('docs-lanes/touch-display.md', 'docs-lanes/touch.md'):
    try:
        c = json.load(urllib.request.urlopen(urllib.request.Request(
            f'https://api.github.com/repos/{REPO}/contents/{name}', headers=H), timeout=60))
        txt = base64.b64decode(c['content']).decode('utf-8', 'replace')
        print('=====', name, '(%d 行)' % len(txt.splitlines()))
        print('\n'.join(txt.splitlines()[:60]))
        break
    except Exception as e:
        print('miss', name, e)

#!/usr/bin/env python3
"""The script refuses an existing output dir; do not pre-create it."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = '.github/workflows/wallpaper.yml'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref=main')
text = base64.b64decode(cur['content']).decode()
old = """          mkdir -p mnt out
          hdiutil attach -nobrowse -readonly -mountpoint mnt os.dmg
          ls mnt | head -20
          python3 ci/make-wallpaper-overlay.py mnt out"""
new = """          mkdir -p mnt
          hdiutil attach -nobrowse -readonly -mountpoint mnt os.dmg
          ls mnt | head -20
          # the script refuses an existing output directory, so do not create out here
          python3 ci/make-wallpaper-overlay.py mnt out"""
if old not in text:
    raise SystemExit('找不到挂载段')
text = text.replace(old, new, 1)

# also try the SystemOS volume when the OS volume has no wallpaper, and keep the volume mounted for a second look
r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data={
    'message': 'ci: do not pre-create the overlay output directory',
    'content': base64.b64encode(text.encode()).decode(),
    'sha': cur['sha'], 'branch': 'main'})
print('已更新', r['commit']['sha'][:8])

time.sleep(15)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if w['name'] == 'wallpaper overlay')
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main', 'inputs': {'dmg': '044-76040-038.dmg'}})
print('已重新触发')

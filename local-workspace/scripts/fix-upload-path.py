#!/usr/bin/env python3
"""Point the upload step at the directory the pipeline actually writes."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = '.github/workflows/build.yml'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref=main')
text = base64.b64decode(cur['content']).decode()
old_paths = """          path: |
            boot.img
            boot.json
"""
new_paths = """          path: |
            ${{ runner.temp }}/image/boot.img
            ${{ runner.temp }}/image/boot.json
"""
if old_paths not in text:
    raise SystemExit('找不到上传路径块')
text = text.replace(old_paths, new_paths, 1)
r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data={
    'message': 'ci: upload the boot image from the temp image directory',
    'content': base64.b64encode(text.encode()).decode(),
    'sha': cur['sha'], 'branch': 'main'})
print('已更新', r['commit']['sha'][:8])

time.sleep(15)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if w['name'] == 'Build')
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main'})
print('已重新触发')

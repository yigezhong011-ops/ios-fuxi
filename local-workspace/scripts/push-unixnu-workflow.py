#!/usr/bin/env python3
"""Push the UniXNU macOS workflow into our fork and dispatch it."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = '.github/workflows/unixnu-macos.yml'
SRC = pathlib.Path('/mnt/e/DSH-Fuxi/ci/unixnu-macos.yml')


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


body = SRC.read_text()
try:
    cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}')
    sha = cur['sha']
    print('已存在，更新')
except Exception:
    sha = None
    print('新建')

payload = {'message': 'ci: build the fuxi UniXNU payload on a macOS runner',
           'content': base64.b64encode(body.encode()).decode(), 'branch': 'main'}
if sha:
    payload['sha'] = sha
r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=payload)
print('pushed', r['commit']['sha'][:8])

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
target = next((w['id'] for w in wfs['workflows'] if w['path'].endswith('unixnu-macos.yml')), None)
print('workflow id', target)
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{target}/dispatches', method='POST',
     data={'ref': 'main', 'inputs': {'steps': 'kernel payload', 'device_ref': 'old'}})
print('已触发 macOS 构建')

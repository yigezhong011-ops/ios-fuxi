#!/usr/bin/env python3
"""Put the load probe back into the bridge and rebuild it in the fork."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=90) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


path = 'tools/mesa-ios/build-bridge.sh'
cur = call(f'https://api.github.com/repos/{REPO}/contents/{path}')
txt = base64.b64decode(cur['content']).decode()
print('当前是否含 probe:', 'fuxi_probe.c' in txt)

if 'fuxi_probe.c' not in txt:
    old = '"$KIT/userland/gl_osmesa.c"'
    new = '"$KIT/userland/gl_osmesa.c" "$KIT/userland/fuxi_probe.c"'
    assert old in txt, 'anchor missing'
    txt = txt.replace(old, new, 1)
    body = {'message': 'mesa-ios: put the load probe back (prove the bridge loads)',
            'content': base64.b64encode(txt.encode()).decode(), 'sha': cur['sha'], 'branch': 'main'}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{path}', method='PUT', data=body)
    print('pushed', r['commit']['sha'][:8])
else:
    print('已经是探针版')

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
target = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('mesa-ios.yml'))
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{target}/dispatches', method='POST',
     data={'ref': 'main', 'inputs': {'winsys': 'fuxi'}})
print('mesa-ios 已触发（探针版）')

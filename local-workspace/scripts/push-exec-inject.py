#!/usr/bin/env python3
"""Push the exec_inject kernel patch and build our kernel with it."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def put(path, data, msg):
    url = f'{API}/contents/{path}'
    body = {'message': msg, 'content': base64.b64encode(data).decode(), 'branch': 'main'}
    try:
        req = urllib.request.Request(url, headers=H)
        cur = json.load(urllib.request.urlopen(req, timeout=30))
        body['sha'] = cur['sha']
    except Exception:
        pass
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={**H, 'Content-Type': 'application/json'}, method='PUT')
    r = json.load(urllib.request.urlopen(req, timeout=60))
    print(f'  {path} -> {r["commit"]["sha"][:8]}')


put('xnu/patches/0116-kern-exec-inject.patch',
    pathlib.Path('/root/fuxi/0116-kern-exec-inject.patch').read_bytes()
    if pathlib.Path('/root/fuxi/0116-kern-exec-inject.patch').exists()
    else pathlib.Path('/mnt/e/DSH-Fuxi/dump/0116-kern-exec-inject.patch').read_bytes(),
    'xnu: kern.exec_inject, so exec() can start backboardd with the EAGL bridge')

disp = json.dumps({'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                             'mesa': False, 'tools': False}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/395549366/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched kernel build')

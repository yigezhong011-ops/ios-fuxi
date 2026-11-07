#!/usr/bin/env python3
"""Make kern.exec_inject say when it fires, so a screen photograph is enough."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/make-exec-inject-patch.py')
src = f.read_text()

marker = 'printf("FUXI INJECT:'
if marker in src:
    print('already logs')
else:
    old = '''		if (matched && liblen != 0 && used + 1 + liblen < size) {'''
    new = '''		if (matched && liblen != 0 && used + 1 + liblen < size) {
			printf("FUXI INJECT: %.*s gets %.*s\\n", (int)namelen, name, (int)liblen, library);'''
    assert old in src, 'anchor missing'
    src = src.replace(old, new, 1)
    f.write_text(src)
    print('added a printk on match')

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


# regenerate the patch, then push it
import subprocess
r = subprocess.run(['python3', '/mnt/e/DSH-Fuxi/dump/wsl/make-exec-inject-patch.py'], capture_output=True, text=True)
print(r.stdout.strip()[:400])

patch = pathlib.Path('/root/fuxi/0116-kern-exec-inject.patch')
put('xnu/patches/0116-kern-exec-inject.patch', patch.read_bytes(),
    'xnu: exec_inject logs the programs it fires for')

disp = json.dumps({'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                             'mesa': False, 'tools': False}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/395549366/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched kernel build')

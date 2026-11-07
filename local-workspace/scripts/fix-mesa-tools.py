#!/usr/bin/env python3
"""Drop the unknown libxml2 option and disable Mesa's tools instead."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
REPO = 'pyhs5g27vr-hue/ios-fuxi'
API = f'https://api.github.com/repos/{REPO}'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh')
src = p.read_text()
src = src.replace('    -Dlibxml2=disabled\n', '')
if '-Dtools=' not in src:
    src = src.replace('    -Dbuild-tests=false\n', '    -Dbuild-tests=false \\\n    -Dtools=\n', 1)
p.write_text(src)
print('options now:')
for line in src.splitlines():
    if line.strip().startswith('-D'):
        print('  ' + line.strip().rstrip('\\').strip())


def put(path, data: bytes, message):
    url = f'{API}/contents/{path}'
    body = {'message': message, 'content': base64.b64encode(data).decode(), 'branch': 'main'}
    try:
        req = urllib.request.Request(url, headers=H)
        cur = json.load(urllib.request.urlopen(req, timeout=30))
        body['sha'] = cur['sha']
    except Exception:
        pass
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={**H, 'Content-Type': 'application/json'}, method='PUT')
    r = json.load(urllib.request.urlopen(req, timeout=60))
    print(f'  pushed {path} -> {r["commit"]["sha"][:8]}')


put('tools/mesa-ios/build.sh', p.read_bytes(), 'mesa-ios: drop libxml2 option, disable Mesa tools')
disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched')

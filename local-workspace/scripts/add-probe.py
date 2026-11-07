#!/usr/bin/env python3
"""Compile the load-visibility probe into the EAGL bridge and rebuild."""
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


put('tools/mesa-ios/userland/fuxi_probe.c',
    pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_probe.c').read_bytes(),
    'mesa-ios: a load-visibility probe compiled into the EAGL bridge')

# add it to the bridge build
p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-bridge.sh')
src = p.read_text()
if 'fuxi_probe.c' not in src:
    src = src.replace('"$KIT/userland/eagl.c" "$KIT/userland/gl_osmesa.c"',
                      '"$KIT/userland/eagl.c" "$KIT/userland/gl_osmesa.c" "$KIT/userland/fuxi_probe.c"')
    p.write_text(src)
    print('bridge now compiles the probe')
put('tools/mesa-ios/build-bridge.sh', p.read_bytes(), 'mesa-ios: compile the probe into the bridge')

wf = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios.yml').read_text()
wf = wf.replace('    env:\n      WINSYS: ${{ inputs.winsys }}\n',
                '    env:\n      WINSYS: ${{ inputs.winsys }}\n')
put('.github/workflows/mesa-ios.yml', wf.encode(), 'mesa-ios: noop (layout kept)')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched')

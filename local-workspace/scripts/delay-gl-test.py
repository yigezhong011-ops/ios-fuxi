#!/usr/bin/env python3
"""Start the test only once the system is up (240 s after launchd starts it),
so the reboot-timing signal lands after the lock screen is visible."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_gl_test.c')
src = f.read_text()

anchor = '\tlogf = fopen(LOG, "a");'
if 'wait for the system to be up' in src:
    print('already delayed')
else:
    assert anchor in src, 'anchor missing'
    src = src.replace(anchor,
                      '\t/* wait for the system to be up: launchd starts us early, long before the lock\n'
                      '\t * screen, and the reboot-timing signal is only readable once it is */\n'
                      '\tsleep(240);\n' + anchor, 1)
    f.write_text(src)
    print('added the 240 s startup delay')

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


put('tools/mesa-ios/experimental/fuxi_gl_test.c', f.read_bytes(),
    'mesa-ios: run the GL test after the system is up so the timing signal is readable')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched')

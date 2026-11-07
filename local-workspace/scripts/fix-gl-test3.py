#!/usr/bin/env python3
"""Drop halt() (not exported on iOS) and rebuild."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_gl_test.c')
src = f.read_text()
src = src.replace('''/* the iOS SDK has no <sys/reboot.h>; libSystem still exports reboot(2) */
extern int reboot(int howto);
extern int halt(void);''', '''/* the iOS SDK has no <sys/reboot.h>; libSystem still exports reboot(2) */
extern int reboot(int howto);''')
src = src.replace('\t\treboot(0);          /* RB_AUTOBOOT: the machine restarts once */\n\t\thalt();             /* if reboot is refused, stop here instead of looping */\n',
                  '\t\treboot(0);          /* RB_AUTOBOOT: the machine restarts once */\n\t\tfor (;;) sleep(60); /* reboot was refused: stay put rather than loop */\n')
f.write_text(src)
print('halt removed:', 'halt()' not in src)

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


put('tools/mesa-ios/experimental/fuxi_gl_test.c', f.read_bytes(), 'mesa-ios: drop halt() from the GL test')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched')

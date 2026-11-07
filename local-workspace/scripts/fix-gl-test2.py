#!/usr/bin/env python3
"""Make the GL test compile: stdarg, mutable attributes, no function/null compare."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_gl_test.c')
src = f.read_text()

# 1) stdarg for va_list in say()
if '#include <stdarg.h>' not in src:
    src = src.replace('#include <stdio.h>', '#include <stdarg.h>\n#include <stdio.h>', 1)

# 2) attributes must be writable (the ES2 fallback rewrites the major version)
src = src.replace('\tconst int attributes[] = {', '\tint attributes[] = {')

# 3) a function name is never null; drop the check that clang rejects
src = src.replace('\tsay("fuxi_gl_test: start (%s)\\n", OSMesaGetProcAddress != NULL ? "symbols resolved" : "no symbols");',
                  '\tsay("fuxi_gl_test: start\\n");')

f.write_text(src)
for marker in ('#include <stdarg.h>', 'int attributes[]', 'fuxi_gl_test: start\\n'):
    print(marker, '->', marker in src)

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


put('tools/mesa-ios/experimental/fuxi_gl_test.c', f.read_bytes(), 'mesa-ios: make the GL test compile')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched')

#!/usr/bin/env python3
"""Push the GL test program + a CI build step for it, then dispatch."""
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


# the test program needs stdarg for say()
src = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_gl_test.c').read_text()
if '#include <stdarg.h>' not in src:
    src = src.replace('#include <stdio.h>', '#include <stdarg.h>\n#include <stdio.h>', 1)
put('tools/mesa-ios/experimental/fuxi_gl_test.c', src.encode(),
    'mesa-ios: a minimal GL test for the device (poweroff = success signal)')

script = '''#!/bin/bash
# Build fuxi_gl_test against the image's libOSMesa.8.dylib.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
B=${BUILD_DIR:-$ROOT/build/mesa-ios}
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
CC=$(xcrun --find clang)
LIB=$B/build-ios/src/gallium/targets/osmesa/libOSMesa.8.dylib
[ -f "$LIB" ] || { echo "missing $LIB"; exit 1; }

"$CC" -arch arm64 -miphoneos-version-min=15.0 -isysroot "$SDK" \\
  -O2 -I"$ROOT/tools/mesa-ios/fuxi-drm" \\
  "$ROOT/tools/mesa-ios/experimental/fuxi_gl_test.c" "$LIB" \\
  -o "$B/fuxi_gl_test"
ls -lh "$B/fuxi_gl_test"
file "$B/fuxi_gl_test" || true
'''
put('tools/mesa-ios/build-gl-test.sh', script.encode(), 'mesa-ios: build the device GL test')

wf = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios.yml')
text = wf.read_text()
text = text.replace('            build/mesa-ios/libredwood-gl.dylib\n',
                    '            build/mesa-ios/libredwood-gl.dylib\n            build/mesa-ios/fuxi_gl_test\n')
if 'Build the device GL test' not in text:
    text = text.replace('      - name: Syntax-check the draft fuxi winsys',
                        '''      - name: Build the device GL test
        run: bash tools/mesa-ios/build-gl-test.sh
      - name: Syntax-check the draft fuxi winsys''')
wf.write_text(text)
put('.github/workflows/mesa-ios.yml', text.encode(), 'mesa-ios: build the device GL test')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched')

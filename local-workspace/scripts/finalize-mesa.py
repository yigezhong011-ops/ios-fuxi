#!/usr/bin/env python3
"""Fix the install name and export the GL symbol list, then rebuild."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
REPO = 'pyhs5g27vr-hue/ios-fuxi'
API = f'https://api.github.com/repos/{REPO}'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh')
src = p.read_text()
tail_old = '''ninja -C build-ios

echo "=== outputs ==="
find build-ios -name '*.dylib' -exec ls -lh {} \\; | head -10
echo MESA_IOS_OK
'''
tail_new = '''ninja -C build-ios

LIB=build-ios/src/gallium/targets/osmesa/libOSMesa.8.dylib
echo "=== install name -> /redwood/lib ==="
install_name_tool -id /redwood/lib/libOSMesa.8.dylib "$LIB"
otool -D "$LIB" | sed -n 2p

echo "=== exported gl* symbols (input for the EAGL bridge generator) ==="
( llvm-nm -gU "$LIB" 2>/dev/null || nm -gU "$LIB" 2>/dev/null ) \\
  | awk '{print $NF}' | grep -E '^_?gl' | sed 's/^_//' | sort -u > build-ios/exported-gl.txt || true
wc -l build-ios/exported-gl.txt

echo "=== outputs ==="
find build-ios -name '*.dylib' -exec ls -lh {} \\; | head -10
echo MESA_IOS_OK
'''
assert tail_old in src, 'tail anchor missing'
src = src.replace(tail_old, tail_new, 1)
p.write_text(src)
print('build.sh: install name + symbol export added')


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


put('tools/mesa-ios/build.sh', p.read_bytes(), 'mesa-ios: set the device install name and export the GL symbols')

wf = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios.yml')
wf.write_text('''name: Mesa iOS

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    runs-on: macos-14
    timeout-minutes: 90
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false
      - name: Build Mesa for arm64-apple-ios
        run: bash tools/mesa-ios/build.sh
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: mesa-ios
          path: |
            build/mesa-ios/build-ios/src/gallium/targets/osmesa/libOSMesa*.dylib
            build/mesa-ios/build-ios/exported-gl.txt
            build/mesa-ios/build-ios/meson-logs/meson-log.txt
          if-no-files-found: warn
''')
put('.github/workflows/mesa-ios.yml', wf.read_bytes(), 'mesa-ios: upload the library and the symbol list')

disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched')

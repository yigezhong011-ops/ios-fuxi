#!/usr/bin/env python3
"""Push the EAGL bridge sources + build script, add the CI step, dispatch."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
REPO = 'pyhs5g27vr-hue/ios-fuxi'
API = f'https://api.github.com/repos/{REPO}'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

U = pathlib.Path('/mnt/e/DSH-Fuxi/mesa-ios/userland')


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
    print(f'  {path} -> {r["commit"]["sha"][:8]}')


for name in ('mkeagl.py', 'eagl.c', 'eagl_slots.txt', 'gl_osmesa.c', 'redwood_gl.h'):
    put(f'tools/mesa-ios/userland/{name}', (U / name).read_bytes(),
        f'mesa-ios: vendor EAGL bridge source {name}')

put('tools/mesa-ios/build-bridge.sh',
    pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-bridge.sh').read_bytes(),
    'mesa-ios: build the EAGL bridge on top of Mesa')

wf = '''name: Mesa iOS

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    runs-on: macos-14
    timeout-minutes: 120
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false
      - name: Build Mesa for arm64-apple-ios
        run: bash tools/mesa-ios/build.sh
      - name: Build the EAGL bridge
        run: bash tools/mesa-ios/build-bridge.sh
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: mesa-ios
          path: |
            build/mesa-ios/build-ios/src/gallium/targets/osmesa/libOSMesa*.dylib
            build/mesa-ios/build-ios/exported-gl.txt
            build/mesa-ios/libredwood-gl.dylib
            build/mesa-ios/eagl_gen.h
            build/mesa-ios/build-ios/meson-logs/meson-log.txt
          if-no-files-found: warn
'''
put('.github/workflows/mesa-ios.yml', wf.encode(), 'mesa-ios: add the EAGL bridge stage')

disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched')

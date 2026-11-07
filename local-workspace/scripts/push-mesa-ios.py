#!/usr/bin/env python3
"""Push the Mesa-iOS build tree to the CI repo and dispatch the workflow."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
REPO = 'pyhs5g27vr-hue/ios-fuxi'
API = f'https://api.github.com/repos/{REPO}'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


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


SRC = pathlib.Path('/mnt/e/DSH-Fuxi/mesa-ios/vendor')
BUILD = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh')

put('tools/mesa-ios/build.sh', BUILD.read_bytes(),
    'mesa-ios: build Mesa for arm64-apple-ios (GLES route, first brick)')
for p in sorted((SRC / 'patches').glob('*.patch')):
    put(f'tools/mesa-ios/patches/{p.name}', p.read_bytes(), f'mesa-ios: vendor {p.name}')
for p in sorted((SRC / 'redwood-drm').glob('*')):
    if p.is_file():
        put(f'tools/mesa-ios/fuxi-drm/{p.name}', p.read_bytes(), f'mesa-ios: vendor drm substitute {p.name}')

wf = '''name: Mesa iOS

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
      - name: Show toolchain
        run: |
          xcrun --sdk iphoneos --show-sdk-path
          xcrun --find clang
      - name: Build Mesa for arm64-apple-ios
        run: bash tools/mesa-ios/build.sh
      - name: Collect
        if: always()
        run: find build -name '*.dylib' -exec ls -lh {} \\; || true
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: mesa-ios
          path: |
            build/mesa-ios/build-ios/**/*.dylib
            build/mesa-ios/build-ios/meson-logs/meson-log.txt
          if-no-files-found: warn
'''
put('.github/workflows/mesa-ios.yml', wf.encode(), 'mesa-ios: CI workflow')

disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched mesa-ios workflow')

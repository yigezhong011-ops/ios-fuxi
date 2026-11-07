#!/usr/bin/env python3
"""Add a syntax-check step for the draft winsys and dispatch."""
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
      - name: Syntax-check the draft fuxi winsys
        if: always()
        run: |
          SDK=$(xcrun --sdk iphoneos --show-sdk-path)
          clang -arch arm64 -isysroot "$SDK" -fsyntax-only \\
            -I build/mesa-ios/mesa-25.0.7/include \\
            -I tools/mesa-ios/fuxi-drm \\
            -I tools/mesa-ios/experimental \\
            tools/mesa-ios/experimental/fuxi_drm.c \\
            && echo WINSYS_SYNTAX_OK
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
put('.github/workflows/mesa-ios.yml', wf.encode(), 'mesa-ios: syntax-check the draft winsys')

disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched')

#!/usr/bin/env python3
"""Let build.sh swap in the fuxi winsys, and add a CI variant that does so."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh')
src = p.read_text()
anchor = '''# the libdrm stand-in lives inside the tree, named as freedreno-darwin.patch expects
rm -rf mesa-$VERSION/src/redwood-drm
cp -r "$KIT"/fuxi-drm mesa-$VERSION/src/redwood-drm
'''
new = '''# the libdrm stand-in lives inside the tree, named as freedreno-darwin.patch expects
rm -rf mesa-$VERSION/src/redwood-drm
cp -r "$KIT"/fuxi-drm mesa-$VERSION/src/redwood-drm
# WINSYS=fuxi swaps in the draft that speaks the NativeAdreno ABI (not yet run on
# hardware): the build then links freedreno against our kernel's wire protocol.
if [ "${WINSYS:-redwood}" = fuxi ]; then
  echo "=== winsys: fuxi (NativeAdreno ABI) ==="
  cp "$KIT/experimental/fuxi_drm.c" mesa-$VERSION/src/redwood-drm/redwood_drm.c
  cp "$KIT/experimental/NativeAdrenoABI.h" mesa-$VERSION/src/redwood-drm/
else
  echo "=== winsys: redwood (reference shim; no device on fuxi, falls back to softpipe) ==="
fi
'''
assert anchor in src
src = src.replace(anchor, new, 1)
p.write_text(src)
print('build.sh: WINSYS switch added')


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


put('tools/mesa-ios/build.sh', p.read_bytes(), 'mesa-ios: WINSYS=fuxi swaps in the NativeAdreno winsys')

wf = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios.yml')
wf.write_text('''name: Mesa iOS

on:
  workflow_dispatch:
    inputs:
      winsys:
        description: Which libdrm stand-in freedreno is built against
        type: choice
        options: [redwood, fuxi]
        default: redwood

permissions:
  contents: read

jobs:
  build:
    runs-on: macos-14
    timeout-minutes: 120
    env:
      WINSYS: ${{ inputs.winsys }}
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
''')
put('.github/workflows/mesa-ios.yml', wf.read_bytes(), 'mesa-ios: winsys input (redwood|fuxi)')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched with winsys=fuxi')

#!/usr/bin/env python3
"""A minimal kernel workflow: no cache steps, one job, one target.

If this also gets cancelled at 15 minutes, the limit is on the account/runner side;
if it completes, the original workflow's cache steps are the problem.
"""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

yml = '''name: Kmin

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  kernel:
    runs-on: macos-14
    timeout-minutes: 120
    env:
      DEVELOPER_DIR: /Applications/Xcode_15.4.app/Contents/Developer
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false
      - name: Build kernel only
        run: |
          echo "start $(date -u +%H:%M:%S)"
          bash tools/ci/build.sh kernel-metal4
          echo "done $(date -u +%H:%M:%S)"
      - name: Upload
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: kmin-kernel
          path: tools/out/ci/kernel-metal4/
          if-no-files-found: warn
          retention-days: 3
'''

path = '.github/workflows/kmin.yml'
body = {'message': 'ci: a minimal kernel job without cache steps', 'content': base64.b64encode(yml.encode()).decode(),
        'branch': 'main'}
try:
    cur = json.load(urllib.request.urlopen(urllib.request.Request(f'{API}/contents/{path}', headers=H), timeout=30))
    body['sha'] = cur['sha']
except Exception:
    pass
req = urllib.request.Request(f'{API}/contents/{path}', data=json.dumps(body).encode(),
                             headers={**H, 'Content-Type': 'application/json'}, method='PUT')
r = json.load(urllib.request.urlopen(req, timeout=60))
print('pushed', r['commit']['sha'][:8])

disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/kmin.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched Kmin')

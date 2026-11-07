#!/usr/bin/env python3
"""Make the UEFI build step fail on error and collect the firmware image."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/hakios-uefi-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = '.github/workflows/uefi.yml'

NEW = '''name: build fuxi uefi

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  uefi:
    runs-on: macos-26
    timeout-minutes: 150
    steps:
      - uses: actions/checkout@v4
      - name: Python deps
        run: |
          python3 -m pip install --break-system-packages --quiet -r pip-requirements.txt || \\
          python3 -m pip install --quiet --user -r pip-requirements.txt
          python3 -c "import edk2toolext, edk2toollib; print('edk2 tools ok')"
      - name: Build
        run: |
          set -o pipefail
          python3 build_uefi.py -d fuxi -r RELEASE > uefi-build.log 2>&1 || {
            echo "=== build failed, tail ==="
            tail -90 uefi-build.log
            exit 1
          }
          tail -25 uefi-build.log
      - name: Collect
        if: always()
        run: |
          mkdir -p out
          find . -name '*.fd' -not -path './.git/*' -exec cp {} out/ \\; 2>/dev/null || true
          cp uefi-build.log out/ 2>/dev/null || true
          ls -l out || true
      - name: Upload
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: fuxi-uefi
          path: out/
          if-no-files-found: warn
          retention-days: 7
'''


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref=main')
r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data={
    'message': 'ci: the build step must fail on error and collect the fd',
    'content': base64.b64encode(NEW.encode()).decode(),
    'sha': cur['sha'], 'branch': 'main'})
print('已更新 workflow', r['commit']['sha'][:8])

time.sleep(15)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if w['name'] == 'build fuxi uefi')
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main'})
print('已重新触发')

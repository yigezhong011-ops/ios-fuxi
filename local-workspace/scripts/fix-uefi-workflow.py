#!/usr/bin/env python3
"""Fix the UEFI workflow's python install and re-dispatch."""
import base64
import json
import pathlib
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
          python3 -m pip install --break-system-packages --quiet -r pip-requirements.txt || \
          python3 -m pip install --quiet --user -r pip-requirements.txt
          python3 -c "import edk2toolext, edk2toollib; print('edk2 tools ok')"
      - name: Build
        run: |
          python3 build_uefi.py -d fuxi -r RELEASE 2>&1 | tail -80
      - name: Collect
        if: always()
        run: |
          mkdir -p out
          find Build -name '*.fd' -exec cp {} out/ \\; 2>/dev/null || true
          find Build -name 'SILICIUM_UEFI.fd' -exec cp {} out/ \\; 2>/dev/null || true
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
    'message': 'ci: install the python deps on the runner',
    'content': base64.b64encode(NEW.encode()).decode(),
    'sha': cur['sha'], 'branch': 'main'})
print('已更新 workflow:', r['commit']['sha'][:8])

import time
time.sleep(15)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if w['name'] == 'build fuxi uefi')
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main'})
print('已重新触发')

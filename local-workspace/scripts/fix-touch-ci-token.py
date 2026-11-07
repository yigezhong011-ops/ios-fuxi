#!/usr/bin/env python3
"""Give the kernel step a token so prepare-xnu-source.py is not rate limited."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = '.github/workflows/kernel.yml'

NEW = '''name: build fuxi touch kernel

on:
  workflow_dispatch:
    inputs:
      defconfig:
        default: fuxi_defconfig
      device_repository:
        default: yigezhong011-ops/fuxi-touch
      device_ref:
        default: main

permissions:
  contents: read

jobs:
  kernel:
    runs-on: macos-26
    timeout-minutes: 180
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      - name: Check out the device repository
        run: |
          git clone --depth 1 --recurse-submodules --branch "${{ inputs.device_ref }}" \\
            "https://github.com/${{ inputs.device_repository }}.git" ../device
      - name: Host tools
        run: brew install dtc llvm lld 2>/dev/null || true
      - name: Configure
        run: ./unixnu defconfig "${{ inputs.defconfig }}" -D ../device
      - name: Build kernel
        env:
          # prepare-xnu-source.py asks the GitHub API for Apple's source list; without a
          # token the hosted runner shares an anonymous limit and gets HTTP 403.
          GITHUB_TOKEN: ${{ github.token }}
        run: |
          set -o pipefail
          ./unixnu build kernel -D ../device 2>&1 | tail -80
      - name: Collect
        if: always()
        run: |
          mkdir -p out
          find . -name 'kernel.macho' -not -path './.git/*' -exec cp {} out/ \\; 2>/dev/null || true
          find . -name 'kernel.json' -not -path './.git/*' -exec cp {} out/ \\; 2>/dev/null || true
          ls -l out || true
      - name: Upload kernel
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: fuxi-touch-kernel
          path: out/
          if-no-files-found: warn
          retention-days: 7
      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: fuxi-touch-logs
          path: |
            out/**/logs/*.log
            **/logs/*.log
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
    'message': 'ci: pass a token to the source fetch step',
    'content': base64.b64encode(NEW.encode()).decode(),
    'sha': cur['sha'], 'branch': 'main'})
print('已更新 workflow', r['commit']['sha'][:8])

time.sleep(15)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if 'touch kernel' in w['name'])
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main', 'inputs': {
         'defconfig': 'fuxi_defconfig',
         'device_repository': 'yigezhong011-ops/fuxi-touch',
         'device_ref': 'main'}})
print('已重新触发')

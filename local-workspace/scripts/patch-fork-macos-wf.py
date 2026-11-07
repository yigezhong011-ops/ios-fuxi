#!/usr/bin/env python3
"""Patch the forked UniXNU macos.yml so the built kernel is uploaded, then run it
for the fuxi device repository (kernel step only, which needs no chip-id secret)."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = '.github/workflows/macos.yml'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}')
text = base64.b64decode(cur['content']).decode()
print('原文件 %d 行' % len(text.splitlines()))

marker = "      - name: Collect the text logs"
upload = """      - name: Upload the built kernel
        if: always() && steps.kernel.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-${{ steps.check.outputs.board }}-kernel-${{ github.run_attempt }}
          path: |
            out/*/kernel/**
          if-no-files-found: warn
          retention-days: 7

"""

if 'Upload the built kernel' in text:
    print('已包含上传步骤')
else:
    if marker not in text:
        raise SystemExit('找不到插入点')
    text = text.replace(marker, upload + marker, 1)
    body = {'message': 'ci: upload the built kernel from the macOS build',
            'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': 'main'}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
    print('已提交', r['commit']['sha'][:8])

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('macos.yml'))
print('workflow id', wf)

call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf}/dispatches', method='POST', data={
    'ref': 'main',
    'inputs': {
        'device_repository': 'ljhhkx529/unixnu-fuxi',
        'device_ref': 'old',
        'defconfig': 'fuxi_full_defconfig',
        'steps': 'kernel',
        'xcode': '26.6',
        'ipsw_url': '',
        'pre_build': '',
        'trust_cache_url': '',
        'owner_trust_cache': False,
        'data_seed_url': '',
        'grow_gib': '',
        'skip_setup': False,
    }})
print('已触发 macOS build（kernel 步骤）')

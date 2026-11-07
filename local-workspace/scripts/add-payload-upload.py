#!/usr/bin/env python3
"""Add a payload upload step next to the kernel upload in our workflow fork."""
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


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref=main')
text = base64.b64decode(cur['content']).decode()

anchor = '      - name: Upload the built kernel'
if 'Upload the built payload' in text:
    print('已经加过 payload 上传步骤')
else:
    insert = '''      - name: Upload the built payload
        if: always() && (contains(inputs.steps, 'payload') || inputs.steps == '')
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-fuxi-payload
          path: |
            out/*/payload/payload.img
            out/*/payload/EFI/UniXNU/**
          if-no-files-found: warn
          retention-days: 7

'''
    if anchor not in text:
        raise SystemExit('找不到上传内核那一步')
    text = text.replace(anchor, insert + anchor, 1)
    body = {'message': 'ci: upload the built payload as well',
            'content': base64.b64encode(text.encode()).decode(),
            'sha': cur['sha'], 'branch': 'main'}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
    print('已提交', r['commit']['sha'][:8])

for line in text.splitlines():
    if 'payload' in line and ('path' in line or 'name:' in line):
        print('  ', line.strip()[:110])

#!/usr/bin/env python3
"""Put the touch device repository's full pipeline in our account, uploading the boot
image in the clear (this is our own private bring-up build)."""
import base64
import json
import pathlib
import subprocess
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
SRC = pathlib.Path('/root/dev-odd')

text = (SRC / '.github/workflows/build.yml').read_text()
lines = text.splitlines()

# find the encrypt step and the upload step, replace them with a plain upload
try:
    start = next(i for i, l in enumerate(lines) if 'Encrypt the boot image' in l)
    end = next(i for i, l in enumerate(lines) if 'Collect the text logs' in l)
except StopIteration:
    raise SystemExit('找不到加密/上传段')

replacement = '''      - name: Upload the boot image
        uses: actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9 # v7.0.2
        with:
          name: fuxi-boot-image-${{ github.run_attempt }}
          path: |
            boot.img
            boot.json
          if-no-files-found: error
          retention-days: 3

'''
new = lines[:start] + replacement.splitlines() + lines[end:]
out = '\n'.join(new) + '\n'
print('新 workflow %d 行（原 %d）' % (len(new), len(lines)))


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/.github/workflows/build.yml?ref=main')
r = call(f'https://api.github.com/repos/{REPO}/contents/.github/workflows/build.yml', method='PUT', data={
    'message': 'ci: upload the boot image in the clear for a private bring-up run',
    'content': base64.b64encode(out.encode()).decode(),
    'sha': cur['sha'], 'branch': 'main'})
print('已更新:', r['commit']['sha'][:8])

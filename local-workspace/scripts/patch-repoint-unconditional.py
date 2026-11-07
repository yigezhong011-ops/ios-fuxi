#!/usr/bin/env python3
"""Make the fork workflow's submodule repoint unconditional: pre_build's unixnu
runs leave a half-initialised directory that defeated the previous guard."""
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

old_step_start = "      - name: Repoint the rewritten QcomXnuUsbDebug submodule"
old_step_end = "      - name: Build kernel"
i, j = text.find(old_step_start), text.find(old_step_end)
if i < 0 or j < 0:
    raise SystemExit('找不到该步骤')

new_step = """      - name: Repoint the rewritten QcomXnuUsbDebug submodule
        run: |
          set -uo pipefail
          # The device repository pins a commit upstream rewrote away, and the
          # pre-build step leaves a half-initialised directory behind: always
          # rebuild it and re-point the gitlink before the kernel build.
          D=device/drivers/QcomXnuUsbDebug
          rm -rf "$D"
          git clone --depth 1 https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$D"
          NEW=$(git -C "$D" rev-parse HEAD)
          git -C device update-index --add --cacheinfo 160000,"$NEW",drivers/QcomXnuUsbDebug
          echo "repointed -> $NEW"
          ls "$D" | head -3

"""
text = text[:i] + new_step + text[j:]
body = {'message': 'ci: always rebuild the rewritten device submodule before building',
        'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': 'main'}
r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
print('已提交', r['commit']['sha'][:8])

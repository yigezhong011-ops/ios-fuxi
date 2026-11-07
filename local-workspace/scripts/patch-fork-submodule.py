#!/usr/bin/env python3
"""Patch the forked UniXNU workflow: repoint the rewritten QcomXnuUsbDebug
submodule in the checked-out device repository before the kernel build runs its
own submodule fetch."""
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

step = """      - name: Repoint the rewritten QcomXnuUsbDebug submodule
        run: |
          set -uo pipefail
          # The device repository pins a commit that upstream rewrote away.
          D=device/drivers/QcomXnuUsbDebug
          if [ ! -f "$D/Makefile" ] && [ ! -e "$D/.git" ]; then
            rm -rf "$D"
            git clone --depth 1 https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$D" || true
            NEW=$(git -C "$D" rev-parse HEAD 2>/dev/null || true)
            if [ -n "$NEW" ]; then
              git -C device update-index --add --cacheinfo 160000,"$NEW",drivers/QcomXnuUsbDebug || true
              echo "repointed -> $NEW"
            fi
          fi
          ls "$D" 2>/dev/null | head -3

"""

marker = "      - name: Build kernel"
if 'Repoint the rewritten QcomXnuUsbDebug submodule' in text:
    print('已经包含该步骤')
else:
    if marker not in text:
        raise SystemExit('找不到 Build kernel 步骤')
    text = text.replace(marker, step + marker, 1)
    body = {'message': 'ci: repoint the rewritten device submodule before the kernel build',
            'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': 'main'}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
    print('已提交', r['commit']['sha'][:8])

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('macos.yml'))
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
print('已重新触发 macOS build')

#!/usr/bin/env python3
"""Build our fork of the fuxi device repository (touch probe, no panic screen)."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('macos.yml'))
try:
    call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf}/dispatches', method='POST', data={
        'ref': 'main',
        'inputs': {
            'device_repository': 'yigezhong011-ops/fuxi-touch',
            'device_ref': 'main',
            'defconfig': 'fuxi_defconfig',
            'steps': 'kernel payload',
            'xcode': '26.6',
            'ipsw_url': '',
            'pre_build': '',
            'trust_cache_url': '',
            'owner_trust_cache': False,
            'data_seed_url': '',
            'grow_gib': '',
            'skip_setup': False,
        }})
    print('已触发：我们的 fuxi-touch 仓库（含 FTS 触控，无 panic 屏）')
except urllib.error.HTTPError as e:
    print('失败', e.code, e.read().decode()[:300])

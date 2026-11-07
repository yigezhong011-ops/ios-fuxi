#!/usr/bin/env python3
"""Kernel + payload with the pinned trust cache, so the root mount authenticates."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
TRUST_URL = 'https://raw.githubusercontent.com/yigezhong011-ops/unixnu-fuxi/old/package/trust-cache.bundle'
PRE_BUILD = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/prebuild-two-pass.txt').read_text()


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('macos.yml'))
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf}/dispatches', method='POST', data={
    'ref': 'main',
    'inputs': {
        'device_repository': 'yigezhong011-ops/unixnu-fuxi',
        'device_ref': 'old',
        'defconfig': 'fuxi_gpu_defconfig',
        'steps': 'kernel payload',
        'xcode': '26.6',
        'ipsw_url': '',
        'pre_build': PRE_BUILD.strip(),
        'trust_cache_url': TRUST_URL,
        'owner_trust_cache': False,
        'data_seed_url': '',
        'grow_gib': '',
        'skip_setup': False,
    }})
print('已触发：kernel + payload（带 pinned trust cache）')

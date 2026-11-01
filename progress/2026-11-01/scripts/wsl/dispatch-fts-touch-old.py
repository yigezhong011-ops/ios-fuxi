#!/usr/bin/env python3
"""Kernel + payload for our format-1 device repository, branch fts-touch (ST FTM5 probe), on the old upstream
(unixnu-ci branch old-tree), the same inputs as dispatch-oldci.py."""
import json
import pathlib
import urllib.error
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PRE_BUILD = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/prebuild-two-pass.txt').read_text()


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
        'ref': 'old-tree',
        'inputs': {
            'device_repository': 'yigezhong011-ops/unixnu-fuxi',
            'device_ref': 'fts-touch',
            'defconfig': 'fuxi_gpu_defconfig',
            'steps': 'kernel payload',
            'xcode': '26.6',
            'ipsw_url': '',
            'pre_build': PRE_BUILD.strip(),
            'trust_cache_url': '',
            'owner_trust_cache': False,
            'data_seed_url': '',
            'grow_gib': '',
            'skip_setup': False,
        }})
    print('dispatched: old-tree + unixnu-fuxi fts-touch')
except urllib.error.HTTPError as e:
    print('failed', e.code, e.read().decode()[:300])

#!/usr/bin/env python3
"""Run the CI with a pre_build that performs the documented two-stage build:
bootstrap (fuxi_defconfig, stage 2a) -> stage the prelink candidate -> full."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

PRE_BUILD = r"""
set -x
./unixnu defconfig fuxi_defconfig -D "$DEVICE_DIR"
./unixnu build kernel -D "$DEVICE_DIR" || true
./unixnu build prelink -D "$DEVICE_DIR" || true
K=out/fuxi/kernel/kernel.macho
D=out/fuxi/tree/build/native-prelink
mkdir -p "$D"
if [ -f "$K" ]; then
  cp "$K" "$D/native-owner-ufs-cpu-desktop-stage2a-candidate.macho"
fi
if [ -f "$K.json" ]; then
  cp "$K.json" "$D/native-owner-ufs-cpu-desktop-stage2a-candidate.json"
fi
ls -l "$D" || true
./unixnu defconfig fuxi_full_defconfig -D "$DEVICE_DIR"
"""


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
        'defconfig': 'fuxi_full_defconfig',
        'steps': 'kernel',
        'xcode': '26.6',
        'ipsw_url': '',
        'pre_build': PRE_BUILD.strip(),
        'trust_cache_url': '',
        'owner_trust_cache': False,
        'data_seed_url': '',
        'grow_gib': '',
        'skip_setup': False,
    }})
print('已触发：两阶段构建（stage 2a → 候选 → full）')

#!/usr/bin/env python3
"""Run the CI: bootstrap with link stubs -> candidate into the device repo ->
full build with the real archive chain."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

PRE_BUILD = r"""
set -x
D=device/drivers/QcomXnuUsbDebug
rm -rf "$D"
git clone --depth 1 https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$D"
NEW=$(git -C "$D" rev-parse HEAD)
git -C device update-index --add --cacheinfo 160000,"$NEW",drivers/QcomXnuUsbDebug

# bootstrap: stubs only, no archive chain
./unixnu defconfig fuxi_bootstrap_defconfig -D "$DEVICE_DIR"
python3 out/fuxi/tree/scripts/build-fuxi-link-stubs.py || python3 "$DEVICE_DIR/scripts/build-fuxi-link-stubs.py"
./unixnu build kernel -D "$DEVICE_DIR"
./unixnu build prelink -D "$DEVICE_DIR"

K=out/fuxi/kernel/kernel.macho
P="$DEVICE_DIR/build/native-prelink"
mkdir -p "$P"
cp "$K" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.macho"
if [ -f "$K.json" ]; then cp "$K.json" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.json"; fi
ls -l "$P"

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
print('已触发：stub bootstrap → 候选 → full')

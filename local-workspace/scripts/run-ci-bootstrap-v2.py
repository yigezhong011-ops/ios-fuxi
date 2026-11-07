#!/usr/bin/env python3
"""Bootstrap run: assemble the tree, build the stubs into it, link, prelink, and
stage the candidate in the device repository for the full build."""
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

./unixnu defconfig fuxi_bootstrap_defconfig -D "$DEVICE_DIR"
./unixnu tree -D "$DEVICE_DIR"
python3 "$DEVICE_DIR/scripts/build-fuxi-link-stubs.py" --out out/fuxi/tree/build/fuxi-link-stubs
ls -l out/fuxi/tree/build/fuxi-link-stubs
./unixnu build kernel -D "$DEVICE_DIR" || true
find out/fuxi -name 'mach.development*noctf' -o -name 'kernel.macho*' | head -5
./unixnu build prelink -D "$DEVICE_DIR" || true

K=out/fuxi/kernel/kernel.macho
P="$DEVICE_DIR/build/native-prelink"
mkdir -p "$P"
if [ -f "$K" ]; then
  cp "$K" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.macho"
  if [ -f "$K.json" ]; then cp "$K.json" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.json"; fi
fi
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
print('已触发：tree → stubs → link → prelink → 候选')

#!/usr/bin/env python3
"""Two-stage CI: a no-archive bootstrap build produces the prelink candidate, the
device repository keeps it (our power-script patch seeds the tree from there),
then the full build runs."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

PRE_BUILD = r"""
set -x
# 1) the device submodule the upstream commit was rewritten away from
D=device/drivers/QcomXnuUsbDebug
rm -rf "$D"
git clone --depth 1 https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$D"
NEW=$(git -C "$D" rev-parse HEAD)
git -C device update-index --add --cacheinfo 160000,"$NEW",drivers/QcomXnuUsbDebug

# 2) bootstrap: no archive chain, so the kernel links and prelinks
./unixnu defconfig fuxi_bootstrap_defconfig -D "$DEVICE_DIR"
./unixnu build kernel -D "$DEVICE_DIR"
./unixnu build prelink -D "$DEVICE_DIR"

# 3) stage the candidate where the device patch seeds it from
K=out/fuxi/kernel/kernel.macho
P="$DEVICE_DIR/build/native-prelink"
mkdir -p "$P"
cp "$K" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.macho"
if [ -f "$K.json" ]; then cp "$K.json" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.json"; fi
ls -l "$P"

# 4) full configuration for the main build
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
print('已触发：bootstrap（无 archive）→ 候选入设备仓库 → full')

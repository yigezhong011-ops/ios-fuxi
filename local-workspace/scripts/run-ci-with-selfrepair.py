#!/usr/bin/env python3
"""pre_build must repair the rewritten submodule itself: it runs before the
workflow's repoint step, so its first unixnu command otherwise dies on the
missing commit and no candidate is ever produced."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

PRE_BUILD = r"""
set -x
# 1) repair the device submodule upstream rewrote away
D=device/drivers/QcomXnuUsbDebug
rm -rf "$D"
git clone --depth 1 https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$D"
NEW=$(git -C "$D" rev-parse HEAD)
git -C device update-index --add --cacheinfo 160000,"$NEW",drivers/QcomXnuUsbDebug
echo "repointed $NEW"

# 2) stage 2a bootstrap build (console only)
./unixnu defconfig fuxi_defconfig -D "$DEVICE_DIR"
./unixnu build kernel -D "$DEVICE_DIR" || true
./unixnu build prelink -D "$DEVICE_DIR" || true

# 3) stage the prelink candidate the full build's audits compare against
K=out/fuxi/kernel/kernel.macho
P=out/fuxi/tree/build/native-prelink
mkdir -p "$P"
if [ -f "$K" ]; then
  cp "$K" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.macho"
fi
if [ -f "$K.json" ]; then
  cp "$K.json" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.json"
fi
ls -l "$P" || true
find out/fuxi -name 'kernel.macho*' 2>/dev/null | head -5 || true

# 4) back to the full configuration for the main build
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
print('已触发：pre_build 内含子模块修复 + 两阶段构建')

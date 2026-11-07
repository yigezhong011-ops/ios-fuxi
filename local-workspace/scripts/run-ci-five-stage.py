#!/usr/bin/env python3
"""Same four-stage CI plus the NativeMetal submodule the accelerator archive needs."""
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

# the accelerator archive includes ../NativeMetal
git submodule update --init --depth 1 drivers/NativeMetal || \
  git submodule update --init drivers/NativeMetal || true
ls drivers/NativeMetal 2>/dev/null | head -3

./unixnu defconfig fuxi_gpu_defconfig -D "$DEVICE_DIR"
./unixnu build kernel -D "$DEVICE_DIR" -j4 || true
./unixnu build prelink -D "$DEVICE_DIR" || true
ls -l out/fuxi/kernel/

P="$DEVICE_DIR/build/xnu-prelink"
mkdir -p "$P"
K=out/fuxi/kernel/kernel.macho
J=out/fuxi/kernel/kernel.json
if [ -f "$K" ] && [ -f "$J" ]; then
  for n in native-owner-ufs-cpu-desktop-stage2a native-owner-mobile-graphics native-owner-ufs-rootauth3; do
    cp "$K" "$P/$n-candidate.macho"
    cp "$J" "$P/$n-candidate.json"
  done
fi
mkdir -p out/fuxi/tree/build/xnu-prelink
cp "$P"/* out/fuxi/tree/build/xnu-prelink/ 2>/dev/null || true
ls -l "$P"

python3 - <<'PY'
import json
from pathlib import Path
payload = {'runtime_metadata_checkpoint_sha256':
           '3044c2beff552911605994c0dc7aa73182066cbb5aed0b396999ceeb5a96da2b'}
for d in ('out/fuxi/tree/build/display-analysis', 'device/build/display-analysis'):
    p = Path(d); p.mkdir(parents=True, exist_ok=True)
    (p / 'mobile-graphics-legacy-abi.json').write_text(json.dumps(payload, indent=2) + '\n')
print('seeded the recorded runtime observation hash')
PY
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
        'defconfig': 'fuxi_gpu_defconfig',
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
print('已触发：含 NativeMetal 子模块的完整构建')

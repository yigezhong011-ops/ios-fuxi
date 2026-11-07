#!/usr/bin/env python3
"""Two-phase CI: the first kernel pass now links, so prelink can emit the candidate;
with it staged, the display audit and the rest of the archive chain can run."""
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

# phase 1: link the kernel so a prelink candidate can exist
./unixnu defconfig fuxi_gpu_defconfig -D "$DEVICE_DIR"
./unixnu build kernel -D "$DEVICE_DIR" -j4 || true
find out/fuxi -name 'mach.development*noctf' | head -3

# phase 2: prelink candidate
./unixnu build prelink -D "$DEVICE_DIR" || true
ls -l out/fuxi/kernel/ 2>/dev/null | head -5

P=out/fuxi/tree/build/xnu-prelink
mkdir -p "$P"
K=out/fuxi/kernel/kernel.macho
if [ -f "$K" ]; then
  cp "$K" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.macho"
  cp "$K" "$P/native-owner-ufs-rootauth3-candidate.macho"
  if [ -f "$K.json" ]; then
    cp "$K.json" "$P/native-owner-ufs-cpu-desktop-stage2a-candidate.json"
    cp "$K.json" "$P/native-owner-ufs-rootauth3-candidate.json"
  fi
fi
ls -l "$P"

# phase 3: the display ABI evidence the legacy display archive needs
python3 out/fuxi/tree/scripts/audit-mobile-graphics-legacy.py || true
ls -l out/fuxi/tree/build/display-analysis/ 2>/dev/null
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
print('已触发：两阶段（先链接出候选，再跑完整 archive 链）')

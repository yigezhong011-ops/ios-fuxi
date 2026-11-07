#!/usr/bin/env python3
"""Build the fuxi format-2 port: prime the build so availability.pl exists, install
it where xnu-8796 looks, then let the real build run."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

PRE_BUILD = r"""
set -x
# xnu 8796 looks for availability.pl inside the SDK; the tree only installs it into
# the fakeroot. Prime the build once, then copy it where the generator expects it.
./unixnu defconfig fuxi_softrender_defconfig -D "$DEVICE_DIR" || true
./unixnu build kernel -D "$DEVICE_DIR" -j4 || true

PL=$(find out -path '*fakeroot/usr/local/libexec/availability.pl' | head -1)
echo "availability.pl: ${PL:-not found}"
SDK=$(xcrun --sdk macosx --show-sdk-path)
echo "SDK: $SDK"
if [ -n "${PL:-}" ]; then
  sudo mkdir -p "$SDK/usr/local/libexec"
  sudo cp "$PL" "$SDK/usr/local/libexec/availability.pl" || true
  sudo chmod 755 "$SDK/usr/local/libexec/availability.pl" || true
  ls -l "$SDK/usr/local/libexec/availability.pl" || true
fi
"""


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
            'device_repository': 'Star-mailaz/fuxi-ios16-device',
            'device_ref': 'main',
            'defconfig': 'fuxi_softrender_defconfig',
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
    print('已触发：先 prime 再把 availability.pl 装进 SDK')
except urllib.error.HTTPError as e:
    print('失败', e.code, e.read().decode()[:300])

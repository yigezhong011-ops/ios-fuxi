#!/usr/bin/env python3
"""Retry the format-2 fuxi kernel with both known build fixes: availability.pl in
every SDK and the fakeroot headers mirrored into the SDKs."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

PRE_BUILD = r"""
set -x
./unixnu defconfig fuxi_softrender_defconfig -D "$DEVICE_DIR" || true
./unixnu build kernel -D "$DEVICE_DIR" -j4 || true

FAKE=$(find out -type d -path '*tree/.cache/fakeroot/usr/local' | head -1)
echo "fakeroot usr/local: ${FAKE:-not found}"
if [ -n "${FAKE:-}" ]; then
  for SDK in /Applications/Xcode_*.app/Contents/Developer/Platforms/*.platform/Developer/SDKs/*.sdk; do
    sudo mkdir -p "$SDK/usr/local/libexec" "$SDK/usr/local/include"
    [ -f "$FAKE/libexec/availability.pl" ] && sudo cp "$FAKE/libexec/availability.pl" "$SDK/usr/local/libexec/" && sudo chmod 755 "$SDK/usr/local/libexec/availability.pl"
    [ -d "$FAKE/include" ] && sudo cp -R "$FAKE/include/." "$SDK/usr/local/include/"
  done
fi
ls /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS*.sdk/usr/local/include/kernel/os/ 2>/dev/null || true
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
    print('已触发：带 Goodix 的 fuxi 内核（iOS 16 那套）')
except urllib.error.HTTPError as e:
    print('失败', e.code, e.read().decode()[:300])

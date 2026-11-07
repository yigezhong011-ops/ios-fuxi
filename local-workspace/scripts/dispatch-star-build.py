#!/usr/bin/env python3
"""Build Star-mailaz's iOS 16 fuxi port (it carries the Goodix touch driver)."""
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-star'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


call(f'https://api.github.com/repos/{REPO}/actions/permissions', method='PUT',
     data={'enabled': True, 'allowed_actions': 'all'})
print('Actions 已启用')

# platform seed for the payload step
from nacl import encoding, public
key = call(f'https://api.github.com/repos/{REPO}/actions/secrets/public-key')
sealed = public.SealedBox(public.PublicKey(key['key'].encode(), encoding.Base64Encoder()))
import base64
call(f'https://api.github.com/repos/{REPO}/actions/secrets/UNIXNU_UNIQUE_CHIP_ID', method='PUT',
     data={'encrypted_value': base64.b64encode(sealed.encrypt(b'0xUNIQUE_CHIP_ID_REDACTED')).decode(),
           'key_id': key['key_id']})
print('已设置平台种子')

time.sleep(12)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
for w in wfs.get('workflows', []):
    print('workflow:', w['name'], w['state'], w['id'])
wf = next(w for w in wfs['workflows'] if w['path'].endswith('macos.yml'))

PRE_BUILD = r"""
set -x
./unixnu defconfig fuxi_softrender_defconfig -D "$DEVICE_DIR" || true
./unixnu build kernel -D "$DEVICE_DIR" -j4 || true
FAKE=$(find out -type d -path '*tree/.cache/fakeroot/usr/local' | head -1)
echo "fakeroot: ${FAKE:-none}"
if [ -n "${FAKE:-}" ]; then
  for SDK in /Applications/Xcode_*.app/Contents/Developer/Platforms/*.platform/Developer/SDKs/*.sdk; do
    sudo mkdir -p "$SDK/usr/local/libexec" "$SDK/usr/local/include"
    [ -f "$FAKE/libexec/availability.pl" ] && { sudo cp "$FAKE/libexec/availability.pl" "$SDK/usr/local/libexec/"; sudo chmod 755 "$SDK/usr/local/libexec/availability.pl"; }
    [ -d "$FAKE/include" ] && sudo cp -R "$FAKE/include/." "$SDK/usr/local/include/"
  done
fi
"""

try:
    call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches', method='POST', data={
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
    print('已触发：Goodix 版 fuxi 内核')
except urllib.error.HTTPError as e:
    print('触发失败', e.code, e.read().decode()[:200])

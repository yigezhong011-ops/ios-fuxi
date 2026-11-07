#!/usr/bin/env python3
"""Set the platform seed secret on the CI repository."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
SEED = '0xUNIQUE_CHIP_ID_REDACTED'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=60) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


from nacl import encoding, public

key = call(f'https://api.github.com/repos/{REPO}/actions/secrets/public-key')
print('key_id:', key['key_id'][:12])
sealed = public.SealedBox(public.PublicKey(key['key'].encode(), encoding.Base64Encoder()))
encrypted = base64.b64encode(sealed.encrypt(SEED.encode())).decode()
call(f'https://api.github.com/repos/{REPO}/actions/secrets/UNIXNU_UNIQUE_CHIP_ID',
     method='PUT', data={'encrypted_value': encrypted, 'key_id': key['key_id']})
print('已设置 UNIXNU_UNIQUE_CHIP_ID =', SEED)

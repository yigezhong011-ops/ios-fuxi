#!/usr/bin/env python3
"""Set the UNIXNU_UNIQUE_CHIP_ID repository secret (the payload step needs the
platform seed for this board)."""
import base64
import json
import pathlib
import subprocess
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
SEED = '0xUNIQUE_CHIP_ID_REDACTED'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=60) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


try:
    import nacl.public  # noqa: F401
except ImportError:
    print('安装 pynacl…')
    subprocess.run([sys.executable, '-m', 'pip', 'install', '-q', 'pynacl'], check=False)

from nacl import encoding, public

key = call(f'https://api.github.com/repos/{REPO}/actions/secrets/public-key')
print('仓库公钥 key_id:', key['key_id'][:12])

sealed = public.SealedBox(public.PublicKey(key['key'].encode(), encoding.Base64Encoder()))
encrypted = base64.b64encode(sealed.encrypt(SEED.encode())).decode()

call(f'https://api.github.com/repos/{REPO}/actions/secrets/UNIXNU_UNIQUE_CHIP_ID',
     method='PUT', data={'encrypted_value': encrypted, 'key_id': key['key_id']})
print('已设置 secret UNIXNU_UNIQUE_CHIP_ID')

secrets = call(f'https://api.github.com/repos/{REPO}/actions/secrets')
print('现有 secrets:', [s['name'] for s in secrets.get('secrets', [])])

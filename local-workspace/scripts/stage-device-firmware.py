#!/usr/bin/env python3
"""Stage the three fuxi GPU firmware blobs exactly as the device pins describe them,
and add a kits-script override that seeds the cache from there."""
import base64
import json
import pathlib
import subprocess
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
DEV = pathlib.Path('/root/fuxi/fork-device')
CACHE = DEV / 'build/firmware/fuxi-gpu'

pins = json.loads((DEV / 'scripts/data/fuxi-adreno-inputs.json').read_text())['firmware']['files']
for key, entry in pins.items():
    repo = entry['repository'].replace('https://github.com/', '')
    sha = entry['git_blob_sha1']
    api = f'https://api.github.com/repos/{repo}/git/blobs/{sha}'
    with urllib.request.urlopen(urllib.request.Request(api, headers=H), timeout=60) as r:
        data = base64.b64decode(json.loads(r.read().decode())['content'])
    target = CACHE / key
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    import hashlib
    print('  %-38s %7d B sha256 %s' % (key, len(data), hashlib.sha256(data).hexdigest()[:16]))
    assert len(data) == entry['bytes'], 'size mismatch for %s' % key
    assert hashlib.sha256(data).hexdigest() == entry['sha256'], 'sha256 mismatch for %s' % key
    assert hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() == sha, 'sha1 mismatch'
print('全部三个固件已按设备 pins 校验通过')

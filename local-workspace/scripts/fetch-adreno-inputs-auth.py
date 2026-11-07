#!/usr/bin/env python3
"""Download every pinned Adreno input with an authenticated API call and stage it
in the device repository, so CI never has to hit the rate-limited endpoint."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
DEV = pathlib.Path('/root/fuxi/fork-device')
CACHE = DEV / 'build/adreno-inputs'

pins = json.loads((DEV / 'scripts/data/adreno-inputs.json').read_text())
print('顶层键:', list(pins.keys()))

def fetch_entry(kind, name, entry):
    repo = entry['repository'].rstrip('/')
    api = repo.replace('https://github.com/', 'https://api.github.com/repos/') + f'/git/blobs/{entry["git_blob_sha1"]}'
    with urllib.request.urlopen(urllib.request.Request(api, headers=H), timeout=60) as r:
        blob = json.loads(r.read().decode())
    data = base64.b64decode(blob['content'])
    out = CACHE / name
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(data)
    print('  %-46s %8d B  (%s)' % (name, len(data), kind))
    return len(data)

total = 0
for kind in ('linux', 'firmware'):
    section = pins.get(kind)
    if not section:
        continue
    print('=== %s ===' % kind)
    for name, entry in section.get('files', {}).items():
        try:
            total += fetch_entry(kind, name, entry)
        except Exception as e:
            print('  %-46s 失败 %s' % (name, e))

print('总计 %d 字节，目录 %s' % (total, CACHE))

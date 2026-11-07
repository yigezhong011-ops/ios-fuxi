#!/usr/bin/env python3
"""Download the tree's pinned Adreno inputs with an authenticated API call and
stage them in the device repository so CI never hits the rate limit."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
DEV = pathlib.Path('/root/fuxi/fork-device')
CACHE = DEV / 'build/adreno-inputs'
PINS = pathlib.Path('/root/ux3/fuxi/tree/scripts/data/adreno-inputs.json')

pins = json.loads(PINS.read_text())
print('顶层键:', list(pins.keys()))

def fetch(kind, name, entry):
    repo = entry['repository'].rstrip('/')
    sha = entry.get('git_blob_sha1') or entry.get('blob') or entry.get('sha1')
    if not sha:
        print('  %-46s 无 blob sha（键: %s）' % (name, list(entry)))
        return 0
    api = repo.replace('https://github.com/', 'https://api.github.com/repos/') + f'/git/blobs/{sha}'
    with urllib.request.urlopen(urllib.request.Request(api, headers=H), timeout=60) as r:
        blob = json.loads(r.read().decode())
    data = base64.b64decode(blob['content'])
    out = CACHE / name
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(data)
    print('  %-46s %8d B' % (name, len(data)))
    return len(data)

total = 0
for kind, section in pins.items():
    if not isinstance(section, dict) or 'files' not in section:
        continue
    print('=== %s ===' % kind)
    for name, entry in section['files'].items():
        if not isinstance(entry, dict):
            continue
        try:
            total += fetch(kind, name, entry)
        except Exception as e:
            print('  %-46s 失败 %s' % (name, e))

print('总计 %d 字节 -> %s' % (total, CACHE))

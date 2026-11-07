#!/usr/bin/env python3
"""Fetch every pinned Adreno input with authentication and stage it in the device
repository, plus a drop-in fetcher that copies from there."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
RAW = {'User-Agent': 'dsh'}
DEV = pathlib.Path('/root/fuxi/fork-device')
CACHE = DEV / 'build/adreno-inputs'
PINS = json.loads(pathlib.Path('/root/ux3/fuxi/tree/scripts/data/adreno-inputs.json').read_text())


def save(name, data):
    out = CACHE / name
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(data)
    return len(data)


total = 0
# linux / board / mesa: raw URLs at the pinned commit
for section in ('linux', 'board', 'mesa'):
    info = PINS.get(section)
    if not info:
        continue
    repo = info['repository'].replace('https://github.com/', '')
    commit = info.get('commit')
    print('=== %s（%s @ %s）===' % (section, repo, (commit or '')[:10]))
    for name in info.get('files', {}):
        url = None
        if repo.startswith('ianchb'):
            url = f'https://raw.githubusercontent.com/{repo}/{commit}/{name}'
        elif 'gitlab.freedesktop.org' in info['repository']:
            mirror = info.get('mirror', '').rstrip('/')
            url = f'{mirror}/+/{commit}/{name}?format=TEXT' if mirror else None
        if not url:
            print('  %-52s 跳过（无 URL）' % name)
            continue
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=RAW), timeout=60) as r:
                data = r.read()
            if url.endswith('?format=TEXT'):
                data = base64.b64decode(data)
            total += save(name, data)
            print('  %-52s %7d B' % (name, len(data)))
        except Exception as e:
            print('  %-52s 失败 %s' % (name, e))

# firmware: blob API
firm = PINS.get('firmware')
if firm:
    repo = firm['repository'].replace('https://github.com/', '')
    print('=== firmware（%s）===' % repo)
    for name, entry in firm.get('files', {}).items():
        sha = entry.get('git_blob_sha1')
        try:
            api = f'https://api.github.com/repos/{repo}/git/blobs/{sha}'
            with urllib.request.urlopen(urllib.request.Request(api, headers=H), timeout=60) as r:
                data = base64.b64decode(json.loads(r.read().decode())['content'])
            total += save(name, data)
            print('  %-52s %7d B' % (name, len(data)))
        except Exception as e:
            print('  %-52s 失败 %s' % (name, e))

print('总计 %.1f MB -> %s' % (total / 1e6, CACHE))

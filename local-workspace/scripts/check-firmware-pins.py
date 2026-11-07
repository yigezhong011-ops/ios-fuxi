#!/usr/bin/env python3
"""Check every firmware pin and test that its blob URL actually resolves."""
import json
import pathlib
import urllib.request

pins = json.loads(pathlib.Path('/root/fuxi/fork-device/scripts/data/fuxi-adreno-inputs.json').read_text())
files = pins['firmware']['files']
for path, entry in files.items():
    repo = entry['repository']
    sha = entry['git_blob_sha1']
    api = repo.rstrip('/').replace('https://github.com/', 'https://api.github.com/repos/') + f'/git/blobs/{sha}'
    status = '?'
    try:
        with urllib.request.urlopen(urllib.request.Request(api, headers={'User-Agent': 'dsh'}), timeout=30) as r:
            body = json.loads(r.read().decode())
            status = '%d %s bytes' % (r.status, body.get('size'))
    except Exception as e:
        status = 'FAIL %s' % e
    print('%-34s %-46s %s' % (path, repo, status))

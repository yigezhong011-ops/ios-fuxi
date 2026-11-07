#!/usr/bin/env python3
"""Patch old-branch build-sheng-platform-power.py so the prelink candidate can
live in the device repository (stable across the tree rebuilds) and be found."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = 'scripts/build-sheng-platform-power.py'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref=old')
text = base64.b64decode(cur['content']).decode()
print('原文件 %d 行' % len(text.splitlines()))

# 1) 需要 os 来读 UNIXNU_DEVICE
if 'import os' not in text:
    text = text.replace('import json\n', 'import json\nimport os\n', 1)

# 2) 在 candidate 检查前插入设备仓库回退
anchor = "if not args.candidate.exists():"
inject = """# The prelink candidate is a qualified input: a clean checkout has none in the
# build tree, so also look in the device repository, where a bootstrap build can
# drop it and keep it across tree rebuilds.
_device = Path(os.environ.get('UNIXNU_DEVICE') or ROOT)
if not args.candidate.exists():
    _shared = sorted((_device / 'build/native-prelink').glob('native-owner-ufs-*-candidate.macho'),
                     key=lambda f: f.stat().st_mtime)
    if _shared:
        args.candidate = _shared[-1]
if not args.candidate.exists():"""
if 'UNIXNU_DEVICE' in text:
    print('已经改过')
else:
    if anchor not in text:
        raise SystemExit('找不到插入点')
    text = text.replace(anchor, inject, 1)
    body = {'message': 'build: also take the prelink candidate from the device repository',
            'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': 'old'}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
    print('已提交', r['commit']['sha'][:8])

for i, line in enumerate(text.splitlines(), 1):
    if 20 <= i <= 34:
        print('%3d| %s' % (i, line[:110]))

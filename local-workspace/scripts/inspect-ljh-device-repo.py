#!/usr/bin/env python3
"""Inspect ljhhkx529/unixnu-fuxi for anything about the USB console."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'ljhhkx529/unixnu-fuxi'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(path, ref):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/{ref}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


info = api(f'https://api.github.com/repos/{REPO}')
ref = info.get('default_branch', 'main')
print('repo:', info.get('full_name'), 'default:', ref, 'pushed:', info.get('pushed_at'))
print('branches:', [b['name'] for b in (api(f'https://api.github.com/repos/{REPO}/branches') or [])][:10])

tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{ref}?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
print('文件 %d 个:' % len(files))
for f in files[:40]:
    print('  ', f)

print('\n=== 文件名含 usb/log 的 ===')
for f in files:
    if any(k in f.lower() for k in ('usb', 'log', 'console')):
        print('  ', f)

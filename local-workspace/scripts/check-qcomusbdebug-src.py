#!/usr/bin/env python3
"""Inspect the QcomXnuUsbDebug driver source for its VBUS handling."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, path, ref='main'):
    try:
        url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return ''


REPO = 'xiaoleGun/QcomXnuUsbDebug'
info = api(f'https://api.github.com/repos/{REPO}')
print('repo:', info.get('full_name'), info.get('default_branch'), '更新', info.get('pushed_at'))

tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{info.get("default_branch", "main")}?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
print('文件 %d 个:' % len(files))
for f in files[:25]:
    print('  ', f)

for f in files:
    if f.endswith(('.c', '.cpp')) and ('usb' in f.lower() or 'dwc' in f.lower() or 'qcom' in f.lower()):
        text = raw(REPO, f)
        hits = [l.strip() for l in text.splitlines() if any(k in l.lower() for k in ('vbus', 'qscratch', 'hs_phy', 'pullup', 'pull-up'))]
        if hits:
            print('\n--- %s（%d 处）---' % (f, len(hits)))
            for line in hits[:10]:
                print('   ', line[:150])

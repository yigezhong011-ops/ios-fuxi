#!/usr/bin/env python3
"""How does the houji port widen kClientWindows? Fetch its source and patches."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
RAW = 'https://raw.githubusercontent.com/{repo}/main/{path}'
REPO = 'lonzzi/UniXNU-houji'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(path, ref='main'):
    try:
        with urllib.request.urlopen(urllib.request.Request(RAW.format(repo=REPO, path=path).replace('/main/', f'/{ref}/'), headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return ''


info = api(f'https://api.github.com/repos/{REPO}')
print('repo:', info.get('full_name'), '默认分支', info.get('default_branch'))
tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{info.get("default_branch", "main")}?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
print('文件数', len(files))
picks = [f for f in files if 'NativeAdrenoPublish' in f or 'client-slot' in f or 'address-space' in f]
for f in picks[:10]:
    print('  ', f)

for f in picks:
    if f.endswith('NativeAdrenoPublish.cpp'):
        text = raw(f)
        if not text:
            continue
        lines = text.splitlines()
        for i, line in enumerate(lines):
            if 'kClientWindows' in line or 'NativeAdrenoMaxClients' in line or 'GeneralClients' in line:
                lo, hi = max(0, i - 6), min(len(lines), i + 30)
                print('\n--- %s:%d ---' % (f, i + 1))
                for j in range(lo, hi):
                    print('   %4d| %s' % (j + 1, lines[j][:160]))
                break

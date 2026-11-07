#!/usr/bin/env python3
"""Find the kClientWindows definition and its bound in the GPU component repos."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
RAW = 'https://raw.githubusercontent.com/{repo}/main/{path}'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, path):
    try:
        with urllib.request.urlopen(urllib.request.Request(RAW.format(repo=repo, path=path), headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


for repo in ('UniXNU/AdrenoMetal', 'UniXNU/Adreno740'):
    tree = api(f'https://api.github.com/repos/{repo}/git/trees/main?recursive=1')
    files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
    hits = []
    for f in files:
        if not f.endswith(('.cpp', '.cc', '.c', '.mm', '.h', '.hpp')):
            continue
        text = raw(repo, f)
        if 'kClientWindows' in text:
            hits.append((f, text))
    print('=== %s: %d 个文件提到 kClientWindows ===' % (repo, len(hits)))
    for f, text in hits:
        lines = text.splitlines()
        for i, line in enumerate(lines):
            if 'kClientWindows' in line:
                lo, hi = max(0, i - 3), min(len(lines), i + 12)
                print('--- %s:%d' % (f, i + 1))
                for j in range(lo, hi):
                    print('   %4d| %s' % (j + 1, lines[j][:150]))
                print()

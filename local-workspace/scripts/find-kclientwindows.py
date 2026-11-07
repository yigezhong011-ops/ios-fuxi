#!/usr/bin/env python3
"""Find kClientWindows in the AdrenoMetal component repository."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for repo in ('UniXNU/AdrenoMetal', 'UniXNU/Adreno740'):
    tree = api(f'https://api.github.com/repos/{repo}/git/trees/main?recursive=1')
    if 'tree' not in tree:
        print(repo, tree)
        continue
    files = [t['path'] for t in tree['tree'] if t['type'] == 'blob']
    print('%s: %d 个文件' % (repo, len(files)))
    cands = [f for f in files if f.endswith(('.cpp', '.cc', '.c', '.mm', '.h', '.hpp'))]
    print('  源码文件 %d 个' % len(cands))
    for f in cands[:12]:
        print('   ', f)

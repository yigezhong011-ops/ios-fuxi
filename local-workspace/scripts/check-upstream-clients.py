#!/usr/bin/env python3
"""Does upstream Adreno740 already declare the five client slots?"""
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


REPO = 'UniXNU/Adreno740'
tree = api(f'https://api.github.com/repos/{REPO}/git/trees/main?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
print('上游 Adreno740 文件 %d 个' % len(files))

keys = ('NativeAdrenoMaxClients', 'NativeAdrenoGeneralClients', 'kClientWindows',
        'PreferencesSlot', 'MaxClients')
hits = {}
for f in files:
    if not f.endswith(('.cpp', '.cc', '.c', '.h', '.hpp')):
        continue
    text = raw(REPO, f)
    for k in keys:
        if k in text:
            hits.setdefault(k, []).append(f)

for k in keys:
    print('%-28s %s' % (k, ', '.join(hits.get(k, [])) or '（没有）'))

# show the constants when found
for f in hits.get('NativeAdrenoMaxClients', [])[:1] + hits.get('kClientWindows', [])[:1]:
    text = raw(REPO, f)
    for i, line in enumerate(text.splitlines()):
        if any(k in line for k in keys):
            print('%s:%d: %s' % (f, i + 1, line.strip()[:150]))

#!/usr/bin/env python3
"""Does Star-mailaz/fuxi-ios16-unixnu carry the iOS 16 OS profile?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'Star-mailaz/fuxi-ios16-unixnu'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


info = api(f'https://api.github.com/repos/{REPO}')
print('repo:', info.get('full_name'), 'fork:', info.get('fork'), 'pushed:', info.get('pushed_at'))
print('parent:', (info.get('parent') or {}).get('full_name'))

profiles = api(f'https://api.github.com/repos/{REPO}/contents/profiles/os')
if isinstance(profiles, list):
    print('profiles/os:', [x['name'] for x in profiles])
else:
    print('profiles/os:', profiles)

wf = api(f'https://api.github.com/repos/{REPO}/contents/.github/workflows')
if isinstance(wf, list):
    print('workflows:', [x['name'] for x in wf])

#!/usr/bin/env python3
"""Full submodule SHAs for the GPU request, plus what changed in each driver repo."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'UniXNU/UniXNU'
SHA = '135b0dabed'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{SHA}?recursive=1')
pins = {t['path']: t['sha'] for t in tree.get('tree', []) if t['type'] == 'commit'}
for name in ('drivers/Adreno740', 'drivers/AdrenoMetal', 'kits/AirNir', 'kits/AdrenoFirmware', 'kits/AdrenoPM4'):
    print('%-24s %s' % (name, pins.get(name, '?')))

print('\n=== 这些驱动最近改了什么 ===')
for repo, sha in (('Adreno740', pins.get('drivers/Adreno740')), ('AdrenoMetal', pins.get('drivers/AdrenoMetal'))):
    url = f'https://api.github.com/repos/UniXNU/{repo}/commits?sha={sha}&per_page=6'
    data = api(url)
    print('\n%s @ %s' % (repo, (sha or '?')[:12]))
    if isinstance(data, list):
        for c in data:
            print('  %s %s  %s' % (c['sha'][:8], c['commit']['author']['date'][:10],
                                   c['commit']['message'].splitlines()[0][:95]))
    else:
        print('  ', data)

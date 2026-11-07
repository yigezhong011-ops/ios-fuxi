#!/usr/bin/env python3
"""Show why the UniXNU macOS run failed: step conclusions and the tail of the
failing step's log."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url, raw=False):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        data = r.read()
        return data.decode() if raw else json.loads(data)


run = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=5')['workflow_runs']
target = next(r for r in run if r['name'].startswith('UniXNU'))
print('run %s %s  %s -> %s' % (target['id'], target['conclusion'], target['created_at'], target['updated_at']))
jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{target["id"]}/jobs')['jobs']
for j in jobs:
    print('job %s %s' % (j['name'], j.get('conclusion')))
    for s in j['steps']:
        print('   %-58s %s' % (s['name'][:58], s.get('conclusion')))
    failing = next((s for s in j['steps'] if s.get('conclusion') == 'failure'), None)
    print('\n    失败步骤:', failing['name'] if failing else '（无）')

#!/usr/bin/env python3
"""Real status of a run: steps and the annotation when it never got a runner."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41737636080'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


r = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}')
print('run', r.get('status'), r.get('conclusion'), 'created', r.get('created_at'), 'updated', r.get('updated_at'))
jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs').get('jobs', [])
for j in jobs:
    print('job', j['id'], j['status'], j['conclusion'], 'runner', j.get('runner_name'), 'labels', j.get('labels'))
    print('  started', j.get('started_at'), 'completed', j.get('completed_at'))
    for s in j.get('steps', []):
        print('   %-24s %-10s %s' % (s['name'], s['status'], s['conclusion']))
ann = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/annotations')
for a in (ann if isinstance(ann, list) else []):
    print('annotation:', a.get('title'), '|', (a.get('message') or '')[:200])

#!/usr/bin/env python3
"""Show the steps and conclusions of the latest UniXNU run."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=2')['workflow_runs']
for r in runs:
    print('run %s %s %s' % (r['id'], r['status'], r.get('conclusion')))
    jobs = call(f'https://api.github.com/repos/{REPO}/actions/runs/{r["id"]}/jobs')['jobs']
    for j in jobs:
        print('  job %s %s' % (j['name'], j.get('conclusion')))
        for s in j['steps']:
            mark = {'success': '+', 'failure': 'X', 'skipped': '-', None: '?'}.get(s.get('conclusion'), '?')
            print('    %s %-58s %s' % (mark, s['name'][:58], s.get('conclusion')))
    print()

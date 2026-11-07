#!/usr/bin/env python3
"""Report the live status of the UniXNU CI run."""
import datetime
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=10')['workflow_runs']
now = datetime.datetime.now(datetime.timezone.utc)
for r in runs:
    if not r['name'].startswith('UniXNU'):
        continue
    created = datetime.datetime.fromisoformat(r['created_at'].replace('Z', '+00:00'))
    age = (now - created).total_seconds() / 60
    print('run %s  status=%s  conclusion=%s  已等 %.0f 分钟'
          % (r['id'], r['status'], r.get('conclusion'), age))
    jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{r["id"]}/jobs')['jobs']
    for j in jobs:
        print('   job %-10s status=%s conclusion=%s' % (j['name'], j['status'], j.get('conclusion')))
        for s in j['steps']:
            print('      %-56s %s' % (s['name'][:56], s.get('status')))

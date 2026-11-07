#!/usr/bin/env python3
"""Step timings for the running job, to see where the time goes."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41737636080'

with urllib.request.urlopen(urllib.request.Request(
        f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs', headers=H), timeout=60) as r:
    job = json.loads(r.read().decode())['jobs'][0]

print('job started', job.get('started_at'), 'status', job['status'])
for s in job['steps']:
    print('  %-24s %-10s %-9s start=%s end=%s' %
          (s['name'], s['status'], s['conclusion'], s.get('started_at'), s.get('completed_at')))

#!/usr/bin/env python3
"""Show step durations of the successful Mesa run to see what fits in 15 minutes."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'

for run in (40826465587, 40852522174):
    jobs = json.load(urllib.request.urlopen(
        urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs/{run}/jobs', headers=H), timeout=60))
    for j in jobs['jobs']:
        print('run', run, 'job', j['name'], j.get('conclusion'))
        for s in j['steps']:
            print('   %-45s %-10s %s -> %s' % (s['name'], s.get('conclusion'), s.get('started_at'), s.get('completed_at')))

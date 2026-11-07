#!/usr/bin/env python3
"""Print the state of the new fork's kernel run."""
import json
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'


def api(u):
    return json.load(urllib.request.urlopen(urllib.request.Request(u, headers=H), timeout=60))


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=3')
for r in runs['workflow_runs']:
    print('run', r['id'], r['name'], r['status'], r.get('conclusion'), r['created_at'])
    if r['status'] != 'completed' or True:
        jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{r["id"]}/jobs')
        for j in jobs['jobs']:
            print('   job %-20s %-12s %s  started %s' % (j['name'], j['status'], j.get('conclusion'), j.get('started_at')))

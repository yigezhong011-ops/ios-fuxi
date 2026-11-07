#!/usr/bin/env python3
"""Show timing and steps of the last few Mesa iOS runs to see why they cancel."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'


def api(u):
    return json.load(urllib.request.urlopen(urllib.request.Request(u, headers=H), timeout=60))


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=6')
for r in runs['workflow_runs']:
    if r['name'] != 'Mesa iOS':
        continue
    print('run %s %s created %s updated %s' % (r['id'], r['conclusion'], r['created_at'], r['updated_at']))
    jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{r["id"]}/jobs')
    for j in jobs['jobs']:
        print('   job %-8s %-10s start %s end %s' % (j['name'], j.get('conclusion'), j.get('started_at'), j.get('completed_at')))
        for s in j['steps']:
            if s.get('conclusion') not in ('success', 'skipped', None):
                print('      %s: %s' % (s.get('conclusion'), s['name']))

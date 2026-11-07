#!/usr/bin/env python3
"""How did the watchdog-patched run end, and is the new one moving?"""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for run in ('41608354328', '41645221755'):
    r = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run}')
    print('run %s: %s / %s  created %s  updated %s' %
          (run, r.get('status'), r.get('conclusion'), r.get('created_at'), r.get('updated_at')))
    jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run}/jobs').get('jobs', [])
    for j in jobs:
        print('  job %s %s %s started=%s' % (j['id'], j['status'], j['conclusion'], j.get('started_at')))
        for s in j.get('steps', []):
            if s.get('conclusion') not in (None, 'success', 'skipped'):
                print('     %-28s %s' % (s['name'], s['conclusion']))
    arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run}/artifacts').get('artifacts', [])
    for a in arts:
        print('  artifact', a['name'], a['size_in_bytes'], 'expired' if a['expired'] else '')
    print()

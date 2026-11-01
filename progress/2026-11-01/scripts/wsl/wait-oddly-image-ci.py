#!/usr/bin/env python3
"""Wait for a GitHub Actions run to finish (checks every 5 min, up to 5 h), then print the job results.
Usage: wait-oddly-image-ci.py <run-id> [owner/repo]   (default repo: our fuxi-touch fork)
       wait-oddly-image-ci.py latest <owner/repo> <branch>   (print the newest run id of that branch and exit)"""
import json
import pathlib
import sys
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
API = 'https://api.github.com/repos/' + (sys.argv[2] if len(sys.argv) > 2 else 'yigezhong011-ops/fuxi-touch')
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        return json.loads(r.read())


run_id = sys.argv[1]
if run_id == 'latest':
    r = get(f'{API}/actions/runs?branch={sys.argv[3]}&per_page=1')['workflow_runs'][0]
    print(r['id'], r['event'], r['status'], r['created_at'], r['html_url'])
    sys.exit(0)
deadline = time.time() + 5 * 3600
last = None
while time.time() < deadline:
    try:
        run = get(f'{API}/actions/runs/{run_id}')
        jobs = get(f'{API}/actions/runs/{run_id}/jobs')['jobs']
    except Exception as e:  # transient network errors: try again next round
        print('error', e, flush=True)
        time.sleep(300)
        continue
    image = next((j for j in jobs if j['name'].startswith('fuxi boot image')), jobs[0] if jobs else None)
    step = next((s['name'] for s in (image or {}).get('steps', []) if s['status'] == 'in_progress'), '')
    now = (run['status'], run['conclusion'], step)
    if now != last:
        print(time.strftime('%H:%M'), *now, flush=True)
        last = now
    if run['status'] == 'completed':
        for j in jobs:
            failed = [s['name'] for s in j['steps'] if s['conclusion'] == 'failure']
            print(' ', j['name'], j['conclusion'], failed or '', flush=True)
        break
    time.sleep(300)

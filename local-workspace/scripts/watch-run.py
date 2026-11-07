#!/usr/bin/env python3
"""Poll the running workflow and print every status change until it finishes."""
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1')['workflow_runs']
run = runs[0]
print('监控 run %s（%s）' % (run['id'], run['created_at']), flush=True)

last = None
deadline = time.time() + 45 * 60
while time.time() < deadline:
    r = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}')
    jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/jobs')['jobs']
    step = None
    if jobs:
        running = [s for s in jobs[0]['steps'] if s.get('status') == 'in_progress']
        step = running[0]['name'] if running else None
    state = (r['status'], r.get('conclusion'), step)
    if state != last:
        print('  %s  status=%s conclusion=%s 当前步骤=%s'
              % (time.strftime('%H:%M:%S'), state[0], state[1], step), flush=True)
        last = state
    if r['status'] == 'completed':
        print('完成:', r.get('conclusion'), flush=True)
        break
    time.sleep(60)

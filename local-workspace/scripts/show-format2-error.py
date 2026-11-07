#!/usr/bin/env python3
"""Show why the input check failed on the format-2 build."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1')['workflow_runs']
run = runs[0]
jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/jobs')['jobs']
job = jobs[0]
print('run', run['id'], run['conclusion'], 'job', job['id'])

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    data = r.read()
lines = data.decode('utf-8', 'replace').splitlines()
print('日志行数', len(lines))
hits = [l for l in lines if '##[error]' in l or 'error:' in l]
for line in hits[:8]:
    print('  ', line[:190])

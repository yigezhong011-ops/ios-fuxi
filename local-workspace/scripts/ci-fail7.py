#!/usr/bin/env python3
"""Show where the newest run stopped."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41638731458'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


run = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}')
print('run', run['id'], run['status'], run['conclusion'], 'sha', run['head_sha'][:8],
      'attempt', run['run_attempt'])
job = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs')['jobs'][0]
for s in job['steps']:
    print('  %-38s %-10s %s' % (s['name'], s['status'], s['conclusion']))

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(
        f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()
print('\n日志 %d 行' % len(lines))
tb = [i for i, l in enumerate(lines) if 'Traceback (most recent call last)' in l]
print('Traceback:', [t + 1 for t in tb])
if tb:
    idx = tb[0]
    for i in range(max(0, idx - 12), min(len(lines), idx + 8)):
        print('%5d| %s' % (i + 1, lines[i][:200]))
else:
    for line in lines[-20:]:
        print(line[:200])

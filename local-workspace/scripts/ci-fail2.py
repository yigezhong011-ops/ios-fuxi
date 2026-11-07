#!/usr/bin/env python3
"""Show the failure context of the GPU addon step in run 41596204631."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41596204631'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


job = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs')['jobs'][0]
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(
        f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()

print('日志 %d 行' % len(lines))
tb = [i for i, l in enumerate(lines) if 'Traceback (most recent call last)' in l]
print('Traceback 位置:', [t + 1 for t in tb])
if tb:
    idx = tb[-1]
    lo = max(0, idx - 40)
    for i in range(lo, min(len(lines), idx + 10)):
        print('%5d| %s' % (i + 1, lines[i][:200]))

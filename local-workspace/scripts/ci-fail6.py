#!/usr/bin/env python3
"""Where did the rerun stop?"""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41600249907'


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
for i, line in enumerate(lines, 1):
    if 'watchdog' in line.lower() and ('did not' in line or 'W 6004' in line):
        print('%5d| %s' % (i, line[:200]))
tb = [i for i, l in enumerate(lines) if 'Traceback (most recent call last)' in l]
if tb:
    idx = tb[0]
    for i in range(max(0, idx - 6), min(len(lines), idx + 6)):
        print('%5d| %s' % (i + 1, lines[i][:200]))

#!/usr/bin/env python3
"""Fetch the failing CI job's log and show the error context."""
import json
import pathlib
import re
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41593554989'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs')['jobs']
job = jobs[0]
print('job:', job['name'], job['conclusion'])
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(
        f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()

print('日志 %d 行' % len(lines))
# find errors
hits = [i for i, l in enumerate(lines)
        if re.search(r'error|Error|failed|Traceback|fatal', l, re.I)]
print('可疑行 %d 处，最后 12 处：' % len(hits))
seen = set()
for i in hits[-12:]:
    if i in seen:
        continue
    seen.add(i)
    print('%5d| %s' % (i + 1, lines[i][:220]))
print('\n=== 最后 25 行 ===')
for line in lines[-25:]:
    print(line[:220])

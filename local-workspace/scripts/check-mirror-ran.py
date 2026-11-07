#!/usr/bin/env python3
"""Did the SDK mirror run and did it find the header?"""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-star'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1')['workflow_runs']
job = api(f'https://api.github.com/repos/{REPO}/actions/runs/{runs[0]["id"]}/jobs')['jobs'][0]
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()

for line in lines:
    if 'fakeroot' in line.lower() and ('fakeroot:' in line or 'cp -R' in line or 'firehose' in line):
        print(line[:190])
print('--- 有没有 firehose 出现在 pre_build 之后 ---')
for line in lines:
    if 'firehose' in line and 'usr/local' in line:
        print(line[:190])

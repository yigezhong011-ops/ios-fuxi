#!/usr/bin/env python3
"""Download the failing 'Build kernel' step log and show where it stopped."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        return r.read()


runs = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1'))['workflow_runs']
run = runs[0]
jobs = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/jobs'))['jobs']
job = jobs[0]
print('run', run['id'], 'job', job['id'])

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']

with urllib.request.urlopen(location, timeout=300) as r:
    data = r.read()
pathlib.Path('/root/ci-step.log').write_bytes(data)
print('下载', len(data), '字节')

lines = data.decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
print('=== 尾部 25 行 ===')
for line in lines[-25:]:
    print('   ', line[:170])

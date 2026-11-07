#!/usr/bin/env python3
"""Why did the fuxi UEFI build fail?"""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/hakios-uefi-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=10')['workflow_runs']
run = next(r for r in runs if r.get('name') == 'build fuxi uefi')
print('run', run['id'], run['conclusion'])
job = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/jobs')['jobs'][0]
for step in job['steps']:
    print('  %-24s %-10s %s' % (step['name'], step['status'], step.get('conclusion') or '-'))

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()
print('--- 末尾 ---')
for line in lines[-25:]:
    print(line[:180])

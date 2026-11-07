#!/usr/bin/env python3
"""Where did the UEFI build put its output?"""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/hakios-uefi-fuxi'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = [r for r in api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=8')['workflow_runs']
        if r.get('name') == 'build fuxi uefi' and r['conclusion'] == 'success']
job = api(f'https://api.github.com/repos/{REPO}/actions/runs/{runs[0]["id"]}/jobs')['jobs'][0]
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()

for line in lines:
    if any(k in line for k in ('.fd', 'FV', 'SILICIUM', 'out', 'Build/')):
        print(line[:185])

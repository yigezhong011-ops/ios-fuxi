#!/usr/bin/env python3
"""Download the failing CI step's log and show the error."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

runs = json.load(urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/runs?per_page=3', headers=H), timeout=60))['workflow_runs']
run = next(r for r in runs if r['name'].startswith('UniXNU'))
print('run', run['id'])

jobs = json.load(urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/jobs', headers=H), timeout=60))['jobs']
job = jobs[0]
req = urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H)
with urllib.request.urlopen(req, timeout=120) as r:
    text = r.read().decode('utf-8', 'replace')

lines = text.splitlines()
start = next((i for i, l in enumerate(lines) if 'Select the configuration' in l), 0)
end = next((i for i, l in enumerate(lines[start + 1:], start + 1) if 'Repoint the rewritten' in l), len(lines))
seg = lines[start:end]
print('该步骤 %d 行，最后 30 行:' % len(seg))
for l in seg[-30:]:
    print('  ' + l[:200])

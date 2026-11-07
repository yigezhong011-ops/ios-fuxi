#!/usr/bin/env python3
"""Cancel the unwanted runs and show the fuxi one."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/hakios-uefi-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=10')['workflow_runs']
for r in runs:
    name = r.get('name') or ''
    print('%-40s %-12s %-10s %s' % (name[:40], r['status'], r.get('conclusion') or '-', r['id']))
    if name != 'build fuxi uefi' and r['status'] in ('queued', 'in_progress'):
        call(f'https://api.github.com/repos/{REPO}/actions/runs/{r["id"]}/cancel', method='POST')
        print('   已取消')

#!/usr/bin/env python3
"""Check a specific run and the newest runs in the fork."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'


def api(u):
    return json.load(urllib.request.urlopen(urllib.request.Request(u, headers=H), timeout=60))


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=5')
for r in runs['workflow_runs']:
    print('run %-12s %-14s %-10s %s' % (r['id'], r['name'], r['status'], r.get('conclusion')))
try:
    r = api(f'https://api.github.com/repos/{REPO}/actions/runs/40821907073')
    print('\n目标 run 40821907073:', r['status'], r.get('conclusion'))
    jobs = api(f'https://api.github.com/repos/{REPO}/actions/runs/40821907073/jobs')
    for j in jobs['jobs']:
        print('  job %-16s %-12s %s' % (j['name'], j['status'], j.get('conclusion')))
        for s in j['steps']:
            if s.get('conclusion') == 'failure':
                print('     失败步骤:', s['name'])
except Exception as e:
    print('目标 run 查询失败:', e)

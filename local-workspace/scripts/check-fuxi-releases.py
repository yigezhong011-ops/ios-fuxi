#!/usr/bin/env python3
"""Does the fuxi port publish prebuilt images?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for repo in ('Star-mailaz/fuxi-ios16-device', 'Star-mailaz/fuxi-ios16-unixnu'):
    rel = api(f'https://api.github.com/repos/{repo}/releases')
    if isinstance(rel, list):
        print(repo, 'releases:', len(rel))
        for r in rel[:3]:
            print('  ', r['tag_name'], r['name'], [(a['name'], a['size']) for a in r.get('assets', [])][:4])
    else:
        print(repo, rel)

    runs = api(f'https://api.github.com/repos/{repo}/actions/runs?per_page=3')
    if isinstance(runs, dict) and 'workflow_runs' in runs:
        print('  最近运行:')
        for r in runs['workflow_runs'][:3]:
            print('   ', r['name'], r['status'], r['conclusion'], r['created_at'])

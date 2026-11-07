#!/usr/bin/env python3
"""List releases (with assets) and recent workflow runs (with artifacts) of a repo (read-only).
Usage: gh-builds.py <owner/repo>"""
import json
import pathlib
import sys
import urllib.error
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def get(url):
    try:
        return json.loads(urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120).read())
    except urllib.error.HTTPError as e:
        return {'error': e.code}


repo = sys.argv[1]
rel = get(f'https://api.github.com/repos/{repo}/releases?per_page=10')
print('releases:', 'none' if not rel else '')
for r in rel if isinstance(rel, list) else []:
    print(f"  {r['published_at']} {r['tag_name']} {r['name']}")
    for a in r['assets']:
        print(f"      {a['name']} {a['size']} {a['updated_at']}")
runs = get(f'https://api.github.com/repos/{repo}/actions/runs?per_page=10')
for r in runs.get('workflow_runs', []):
    print(f"run {r['id']} {r['created_at']} {r['head_branch']} {r['name']} {r['status']}/{r['conclusion']}")
    arts = get(r['artifacts_url'])
    for a in arts.get('artifacts', []):
        print(f"      artifact {a['name']} {a['size_in_bytes']} expired={a['expired']}")

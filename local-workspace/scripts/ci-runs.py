#!/usr/bin/env python3
"""List recent workflow runs of a repo with branch, title and result, plus artifacts (read-only).
Usage: ci-runs.py <owner/repo> [count]"""
import json
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def get(url):
    return json.loads(urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120).read())


repo = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 15
for r in get(f'https://api.github.com/repos/{repo}/actions/runs?per_page={n}')['workflow_runs']:
    print(f"{r['id']} {r['created_at']} {r['updated_at'][11:19]} {r['head_branch']:10} {r['status']}/{r['conclusion']} {r['display_title'][:70]}")
    if r['conclusion'] == 'success':
        for a in get(r['artifacts_url']).get('artifacts', []):
            print(f"      artifact {a['name']} {a['size_in_bytes']} expired={a['expired']}")

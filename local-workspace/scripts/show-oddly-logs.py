#!/usr/bin/env python3
"""Download this run's logs and show why the OddlyLabs kernel build failed."""
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1')['workflow_runs']
run = runs[0]
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts')['artifacts']
print('artifacts:', [(a['name'], a['size_in_bytes']) for a in arts])

target = next((a for a in arts if 'log' in a['name']), None)
if target:
    opener = urllib.request.build_opener(NoRedirect)
    try:
        opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
    except urllib.error.HTTPError as e:
        location = e.headers['Location']
    with urllib.request.urlopen(location, timeout=600) as r:
        data = r.read()
    out = pathlib.Path('/root/art-oddly-logs.zip')
    out.write_bytes(data)
    with zipfile.ZipFile(out) as z:
        name = next((n for n in z.namelist() if 'kernel' in n), z.namelist()[0])
        lines = z.read(name).decode('utf-8', 'replace').splitlines()
        print('=== %s（%d 行）=== ' % (name, len(lines)))
        hits = [l for l in lines if 'error' in l.lower() or 'fail' in l.lower() or 'missing' in l.lower()]
        for line in hits[-15:]:
            print('  ', line[:190])

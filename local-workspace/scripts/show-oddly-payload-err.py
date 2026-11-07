#!/usr/bin/env python3
"""Why did the payload step fail? Show payload-patch.log lines if present."""
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
if not target:
    raise SystemExit('没有日志产物')

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=600) as r:
    data = r.read()
pathlib.Path('/root/art-oddly-logs.zip').write_bytes(data)

with zipfile.ZipFile('/root/art-oddly-logs.zip') as z:
    names = z.namelist()
    print('包内:', [n for n in names if 'payload' in n or 'kernel' in n][:6])
    for name in names:
        if 'payload' in name:
            lines = z.read(name).decode('utf-8', 'replace').splitlines()
            print('=== %s（%d 行）===' % (name, len(lines)))
            for line in lines[-14:]:
                print('   ', line[:180])

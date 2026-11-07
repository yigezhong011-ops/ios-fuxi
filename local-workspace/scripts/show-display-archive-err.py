#!/usr/bin/env python3
"""Show the native-legacy-display archive failure."""
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
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{runs[0]["id"]}/artifacts')['artifacts']
target = next((a for a in arts if 'log' in a['name']), None)
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=600) as r:
    pathlib.Path('/root/art-fuxitouch-logs.zip').write_bytes(r.read())

with zipfile.ZipFile('/root/art-fuxitouch-logs.zip') as z:
    for name in z.namelist():
        if 'legacy-display' in name or 'platform-power' in name:
            lines = z.read(name).decode('utf-8', 'replace').splitlines()
            print('=== %s（%d 行）===' % (name, len(lines)))
            for line in lines[-16:]:
                print('   ', line[:185])
            print()

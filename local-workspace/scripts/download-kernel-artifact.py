#!/usr/bin/env python3
"""Download the built kernel artifact."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        return r.read()


runs = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1'))['workflow_runs']
run = runs[0]
print('run', run['id'], run['conclusion'])
arts = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts'))
for a in arts['artifacts']:
    print('  artifact:', a['name'], a['size_in_bytes'], 'bytes')

target = next((a for a in arts['artifacts'] if 'kernel' in a['name'].lower()), None)
if not target:
    raise SystemExit('没找到内核产物')

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']

with urllib.request.urlopen(location, timeout=600) as r:
    data = r.read()
out = pathlib.Path('/root/kernel-artifact.zip')
out.write_bytes(data)
print('已下载', len(data), '字节 ->', out)

import zipfile
with zipfile.ZipFile(out) as z:
    for info in z.infolist():
        print('   %-40s %10d B' % (info.filename, info.file_size))

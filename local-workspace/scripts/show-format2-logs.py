#!/usr/bin/env python3
"""Download this run's logs artifact and show the symbol-aliasing failure."""
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
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts')
print('artifacts:', [(a['name'], a['size_in_bytes']) for a in arts['artifacts']])
target = next((a for a in arts['artifacts'] if 'log' in a['name']), None)
if not target:
    raise SystemExit('没有日志产物')

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=600) as r:
    data = r.read()
out = pathlib.Path('/root/art-format2-logs.zip')
out.write_bytes(data)
print('下载', len(data), '字节')

with zipfile.ZipFile(out) as z:
    names = z.namelist()
    print('包内:', names[:8])
    boot = next((n for n in names if 'bootstrap' in n), None)
    if boot:
        lines = z.read(boot).decode('utf-8', 'replace').splitlines()
        print('=== %s（%d 行）前 30 行 ===' % (boot, len(lines)))
        for line in lines[:30]:
            print('   ', line[:175])

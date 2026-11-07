#!/usr/bin/env python3
"""Download the log artifact (the redirect target is Azure blob storage, which
rejects the API token) and print the bootstrap link failure."""
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        return r.read()


opener = urllib.request.build_opener(NoRedirect)
runs = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1'))['workflow_runs']
run = runs[0]
arts = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts'))
target = next(a for a in arts['artifacts'] if 'log' in a['name'].lower())

try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
    raise SystemExit('没有重定向')
except urllib.error.HTTPError as e:
    if e.code not in (301, 302, 303, 307, 308):
        raise
    location = e.headers['Location']

with urllib.request.urlopen(location, timeout=300) as r:
    data = r.read()
out = pathlib.Path('/root/ci-logs.zip')
out.write_bytes(data)
print('已下载', len(data), '字节')

with zipfile.ZipFile(out) as z:
    names = z.namelist()
    print('包内:', names)
    for want in ('kernel-bootstrap', 'archive-01'):
        match = next((n for n in names if want in n), None)
        if not match:
            continue
        text = z.read(match).decode('utf-8', 'replace')
        lines = text.splitlines()
        print()
        print('=== %s（%d 行）尾部 ===' % (match, len(lines)))
        for line in lines[-25:]:
            print('   ', line[:170])

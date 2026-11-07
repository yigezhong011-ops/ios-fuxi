#!/usr/bin/env python3
"""Download the fuxi UEFI artifact."""
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/hakios-uefi-fuxi'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = [r for r in api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=8')['workflow_runs']
        if r.get('name') == 'build fuxi uefi' and r['conclusion'] == 'success']
run = runs[0]
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts')
print('artifacts:', [(a['name'], a['size_in_bytes']) for a in arts['artifacts']])

opener = urllib.request.build_opener(NoRedirect)
for a in arts['artifacts']:
    try:
        opener.open(urllib.request.Request(a['archive_download_url'], headers=H), timeout=60)
        continue
    except urllib.error.HTTPError as e:
        location = e.headers['Location']
    with urllib.request.urlopen(location, timeout=600) as r:
        data = r.read()
    out = pathlib.Path('/root/fuxi-uefi.zip')
    out.write_bytes(data)
    print('下载', len(data), '字节')
    with zipfile.ZipFile(out) as z:
        for info in z.infolist():
            print('  %-46s %10d B' % (info.filename, info.file_size))
        z.extractall('/root/fuxi-uefi')
print('解到 /root/fuxi-uefi')

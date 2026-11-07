#!/usr/bin/env python3
"""Download the newest unixnu-ci artifacts (payload + kernel)."""
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1')['workflow_runs']
run = runs[0]
print('run', run['id'], run['status'], run['conclusion'])
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts')['artifacts']
print('artifacts:', [(a['name'], a['size_in_bytes']) for a in arts])

opener = urllib.request.build_opener(NoRedirect)
for a in arts:
    if 'log' in a['name']:
        continue
    try:
        opener.open(urllib.request.Request(a['archive_download_url'], headers=H), timeout=60)
    except urllib.error.HTTPError as e:
        location = e.headers['Location']
    with urllib.request.urlopen(location, timeout=900) as r:
        data = r.read()
    out = pathlib.Path('/root/art-ci-%s.zip' % a['name'])
    out.write_bytes(data)
    print('下载 %-28s %d 字节' % (a['name'], len(data)))
    with zipfile.ZipFile(out) as z:
        for info in z.infolist():
            print('   ', info.filename, info.file_size)
            if info.filename.endswith('payload.img'):
                pathlib.Path('/root/fuxi/ci-payload.img').write_bytes(z.read(info))
                print('    → /root/fuxi/ci-payload.img')
            elif info.filename.endswith('kernel.macho'):
                pathlib.Path('/root/fuxi/ci-kernel.macho').write_bytes(z.read(info))
                print('    → /root/fuxi/ci-kernel.macho')

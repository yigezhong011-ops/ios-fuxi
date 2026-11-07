#!/usr/bin/env python3
"""Download every artifact of the newest run and list their contents."""
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


runs = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1'))['workflow_runs']
run = runs[0]
arts = json.loads(api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts'))
opener = urllib.request.build_opener(NoRedirect)

for a in arts['artifacts']:
    name = a['name']
    print('=== %s（%d 字节）===' % (name, a['size_in_bytes']))
    try:
        opener.open(urllib.request.Request(a['archive_download_url'], headers=H), timeout=60)
        continue
    except urllib.error.HTTPError as e:
        location = e.headers['Location']
    with urllib.request.urlopen(location, timeout=600) as r:
        data = r.read()
    out = pathlib.Path('/root/art-%s.zip' % name.replace('/', '_'))
    out.write_bytes(data)
    with zipfile.ZipFile(out) as z:
        for info in z.infolist():
            print('   %-46s %10d B' % (info.filename, info.file_size))
    print()

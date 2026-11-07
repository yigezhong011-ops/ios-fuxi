#!/usr/bin/env python3
"""Download the kernel built with the FTS touch probe."""
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = 41277721246


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/artifacts')['artifacts']
print('artifacts:', [(a['name'], a['size_in_bytes']) for a in arts])
target = next(a for a in arts if 'kernel' in a['name'])
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=900) as r:
    data = r.read()
out = pathlib.Path('/root/art-touch-kernel.zip')
out.write_bytes(data)
print('下载', len(data), '字节')

with zipfile.ZipFile(out) as z:
    for info in z.infolist():
        print('  ', info.filename, info.file_size)
        if info.filename.endswith('kernel.macho'):
            pathlib.Path('/root/fuxi/touch-kernel.macho').write_bytes(z.read(info))
            print('   已保存 /root/fuxi/touch-kernel.macho')

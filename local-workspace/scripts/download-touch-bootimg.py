#!/usr/bin/env python3
"""Download the fuxi touch boot image."""
import json
import pathlib
import shutil
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/fuxi-touch'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1')['workflow_runs']
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{runs[0]["id"]}/artifacts')
target = next(a for a in arts['artifacts'] if 'boot-image' in a['name'])
print('artifact:', target['name'], target['size_in_bytes'])

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=600) as r:
    data = r.read()
zip_path = pathlib.Path('/root/fuxi-boot-image.zip')
zip_path.write_bytes(data)
print('下载', len(data), '字节')

with zipfile.ZipFile(zip_path) as z:
    for info in z.infolist():
        print('   %-30s %10d B' % (info.filename, info.file_size))
    z.extractall('/root/fuxi-boot-image')

for src in pathlib.Path('/root/fuxi-boot-image').rglob('boot.img'):
    dst = pathlib.Path('/mnt/e/DSH-Fuxi/fuxi-touch-boot.img')
    shutil.copyfile(src, dst)
    print('已复制到', dst, dst.stat().st_size, '字节')
    break

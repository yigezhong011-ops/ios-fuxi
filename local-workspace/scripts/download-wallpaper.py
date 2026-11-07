#!/usr/bin/env python3
"""Download the wallpaper overlay and report the file sizes."""
import json
import pathlib
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


runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=3')['workflow_runs']
run = next(r for r in runs if r.get('name') == 'wallpaper overlay' and r['conclusion'] == 'success')
arts = api(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts')
target = next(a for a in arts['artifacts'] if a['name'] == 'wallpaper-overlay')

opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(target['archive_download_url'], headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=600) as r:
    data = r.read()
zip_path = pathlib.Path('/root/wallpaper-overlay.zip')
zip_path.write_bytes(data)
print('下载 %d 字节' % len(data))
with zipfile.ZipFile(zip_path) as z:
    for info in z.infolist():
        print('  %-24s %10d B' % (info.filename, info.file_size))
    z.extractall('/root/wallpaper-overlay')
print('解到 /root/wallpaper-overlay')

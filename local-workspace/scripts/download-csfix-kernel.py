#!/usr/bin/env python3
"""Download the kernel artifact from the successful run."""
import io
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'
RUN = 40821907073

arts = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/artifacts', headers=H), timeout=60))
for a in arts['artifacts']:
    print('artifact', a['name'], round(a['size_in_bytes'] / 1e6, 1), 'MB')

a = arts['artifacts'][0]
url = f'https://api.github.com/repos/{REPO}/actions/artifacts/{a["id"]}/zip'
data = urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=300).read()
out = pathlib.Path('/mnt/e/DSH-Fuxi/kernel-inject')
out.mkdir(exist_ok=True)
zf = zipfile.ZipFile(io.BytesIO(data))
for n in zf.namelist():
    print('  ', n)
    if n.endswith('kernel.development.fuxi'):
        target = out / 'kernel.csfix.fuxi'
        target.write_bytes(zf.read(n))
        print('saved', target, target.stat().st_size)
    elif n.endswith('kernel.development.fuxi.unstripped'):
        (out / 'kernel.csfix.unstripped').write_bytes(zf.read(n))

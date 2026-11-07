#!/usr/bin/env python3
"""Download the probe-free bridge from the successful Mesa iOS run."""
import io
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'
RUN = 40826465587

arts = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/artifacts', headers=H), timeout=60))
a = arts['artifacts'][0]
print('artifact', a['name'], round(a['size_in_bytes'] / 1e6, 1), 'MB')

data = urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/artifacts/{a["id"]}/zip', headers=H), timeout=300).read()
zf = zipfile.ZipFile(io.BytesIO(data))
out = pathlib.Path('/mnt/e/DSH-Fuxi/gles-stack')
for n in zf.namelist():
    print('  ', n)
    base = pathlib.Path(n).name
    if base in ('libredwood-gl.dylib', 'libOSMesa.8.dylib'):
        (out / base).write_bytes(zf.read(n))
        print('   ->', out / base, (out / base).stat().st_size)
